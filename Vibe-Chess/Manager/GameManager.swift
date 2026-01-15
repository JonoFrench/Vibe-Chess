//
//  GameManager.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 30.12.25.
//

import Foundation
import SwiftUI
import UIKit
import Combine

enum GameResult: Equatable {
    case checkmate(winner: PieceColor)
    case stalemate
    case drawByFiftyMoveRule
    case drawByThreefoldRepetition
    case timeout(winner: PieceColor)
    case resignation(winner: PieceColor)
}

struct CastlingRights: Codable, Equatable, Hashable {
    var whiteKingSide = true
    var whiteQueenSide = true
    var blackKingSide = true
    var blackQueenSide = true
}

struct PromotionRequest: Identifiable, Equatable {
    let id = UUID()
    let square: Square
    let color: PieceColor
}

struct PositionKey: Hashable {
    let boardHash: String
    let sideToMove: PieceColor
    let castlingRights: CastlingRights
}

struct ChessClock:Codable, Equatable {
    var whiteTime: TimeInterval
    var blackTime: TimeInterval
    var isRunning: Bool = false
}

enum TimeControl: String, CaseIterable, Identifiable {
    case three = "3 min"
    case five = "5 min"
    case ten = "10 min"
    case fifteen = "15 min"

    var id: String { rawValue }

    var seconds: TimeInterval {
        switch self {
        case .three: return 3 * 60
        case .five: return 5 * 60
        case .ten: return 10 * 60
        case .fifteen: return 15 * 60
        }
    }
}

@MainActor
final class GameManager: ObservableObject {
    
    @Published private(set) var board = Board.standard()
    @Published private(set) var sideToMove: PieceColor = .white
    @Published var selectedSquare: Square? = nil
    @Published private(set) var gameResult: GameResult? = nil
    @Published var lastCapturedSquare: Square? = nil
    @Published var lastMove: Move? = nil
    @Published private(set) var castlingRights = CastlingRights()
    @Published var pendingPromotion: PromotionRequest? = nil
    @Published private(set) var moveHistory: [MoveRecord] = []
    @Published var isThinking = false
    @Published private(set) var halfMoveClock: Int = 0
    @Published private(set) var enPassantTarget: Square? = nil
    @Published var isDemoMode: Bool = false
    @Published var highlightedSquares: Set<Square> = []
    @Published var rotateBlackPieces: Bool = false
    @Published var showCoordinates: Bool = true
    @Published var showLastMove: Bool = true
    @Published var clock = ChessClock(
        whiteTime: 1 * 60,
        blackTime: 1 * 60
    )
    @Published var timeControl: TimeControl = .three
    @Published var stagedMove: Move? = nil
    @Published var paused = false
    private var clockTimer: Timer?

    private var positionCounts: [PositionKey: Int] = [:]
    private let ai = SimpleChessAI()
    var playAgainstAI = true
    var squareDimension = 0.0
    var previousHalfMoveClock = 0
    var previousPositionCounts: [PositionKey: Int] = [:]
    var previousEnPassantTarget: Square?
    var canUndo: Bool {
        !moveHistory.isEmpty
    }
    var gameStarted = false

    init() {
        if UIDevice.current.userInterfaceIdiom == .pad {
        } else {
            
        }
#if DEBUG
        //loadStalemateTestPosition()
        //loadCheckmateTestPosition()
//        loadUnsafeMoveTestPosition()
//        loadPromotionTestPosition()
//        loadCastlingTest()
#endif
        
    }
 
    func setBoard(_ newBoard: Board) {
        board = newBoard
    }
    
    func setCastlingRights(_ newCastlingRights: CastlingRights) {
        castlingRights = newCastlingRights
    }

    func select(_ square: Square) {
        if !gameStarted && !playAgainstAI {
            gameStarted = true
            startClock()
        }
        guard let piece = board[square] else {
            // Tap on empty square
            if let from = selectedSquare {
                if playAgainstAI {
                    attemptMove(from: from, to: square)
                } else {
                    stageMove(from: from, to: square)
                }
            }
            selectedSquare = nil
            return
        }
        
        // Tap on a piece
        if piece.color == sideToMove {
            // Select or re-select your own piece
            selectedSquare = square
        } else if let from = selectedSquare {
            // Capture opponent piece
            attemptMove(from: from, to: square)
            selectedSquare = nil
        }
    }
    
//    func stageMove(_ move: Move) {
//        withAnimation(.easeInOut(duration: 0.2)) {
//            stagedMove = move
//        }
//    }

    func clearStagedMove() {
        withAnimation(.easeInOut(duration: 0.15)) {
            stagedMove = nil
        }
    }

    func stageMove(from: Square, to: Square) {
        withAnimation(.easeInOut(duration: 0.2)) {
            let moves = legalMoves(from: from)
            guard let move = moves.first(where: { $0.to == to }) else { return }
            
            stagedMove = move
        }
    }

    func commitStagedMove() {
        guard let move = stagedMove else { return }

        stagedMove = nil
        executeMove(move)
    }

    func stagedPiece(at square: Square) -> Piece? {
        guard let move = stagedMove else { return nil }
        guard let piece = board[move.from] else { return nil }

        if square == move.to { return piece }
        return nil
    }

    func isStagedFromSquare(_ square: Square) -> Bool {
        stagedMove?.from == square
    }

    var stagedFromSquare: Square? {
        stagedMove?.from
    }

    var stagedToSquare: Square? {
        stagedMove?.to
    }

    
    func executeMove(_ move: Move) {
        guard let piece = board[move.from] else { return }

        let capturedPiece = board[move.to]
        let isCheck = board.isKingInCheck(color: sideToMove, enPassantTarget: nil)
        let isCheckmate = board.isCheckmate(for: sideToMove)

        let ambiguousPieces = board.findAmbiguousPieces(
            for: piece,
            movingTo: move.to
        )

        let disambiguationFile = ambiguousPieces.contains {
            $0.from.file != move.from.file
        }

        let disambiguationRank = ambiguousPieces.contains {
            $0.from.rank != move.from.rank
        }

        let record = MoveRecord(
            move: move,
            movedPiece: piece,
            capturedPiece: capturedPiece,
            previousCastlingRights: castlingRights,
            previousSideToMove: sideToMove,
            previousGameResult: gameResult,
            previousHalfMoveClock: halfMoveClock,
            previousPositionCounts: positionCounts,
            previousEnPassantTarget: enPassantTarget,
            rookMove: rookCastlingMoveIfNeeded(move, piece),
            promotion: move.promotion,
            isCheck: isCheck,
            isCheckmate: isCheckmate,
            disambiguationFile: disambiguationFile,
            disambiguationRank: disambiguationRank,
//            previousClock:
        )

        applyMove(record)
        moveHistory.append(record)
    }

    func submitMove(_ move: Move) {
//        makeMove(move)
        executeMove(move)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.handleAIMoveIfNeeded()
        }
    }
    
    private func applyMove(_ record: MoveRecord) {
        let move = record.move
        let piece = record.movedPiece

        withAnimation(.easeInOut(duration: 0.25)) {

            updateCastlingRights(piece: piece, from: move.from)

            board[move.from] = nil
            if enPassantTarget != nil {
                let ept = enPassantCaptureSquare(for: move, pawn: piece)
                if let ept {
                    print("enPassantTarget \(ept)")
                    board[ept] = nil
                }
                self.enPassantTarget = nil // default reset
            }
            if let promotion = record.promotion {
                board[move.to] = Piece(type: promotion, color: piece.color)
            } else {
                board[move.to] = piece
            }

            if let rookMove = record.rookMove {
                let rook = board[rookMove.from]
                board[rookMove.from] = nil
                board[rookMove.to] = rook
            }
            previousHalfMoveClock = halfMoveClock
            previousPositionCounts = positionCounts
            previousEnPassantTarget = enPassantTarget
            let isPawnMove = piece.type == .pawn
            let isCapture = board[move.to] != nil

            if isPawnMove || isCapture {
                halfMoveClock = 0
            } else {
                halfMoveClock += 1
            }
            
            if piece.type == .pawn {
                let startRank = piece.color == .white ? 1 : 6
                let doublePushRank = piece.color == .white ? 3 : 4

                if move.from.rank == startRank && move.to.rank == doublePushRank {
                    enPassantTarget = Square(
                        file: move.from.file,
                        rank: (move.from.rank + move.to.rank) / 2
                    )
                }
            }

            sideToMove = sideToMove.opponent
            lastMove = move
//            startClock()
        }

        checkForGameEnd()
    }

    func enPassantCaptureSquare(for move: Move, pawn: Piece) -> Square? {
        guard pawn.type == .pawn,
              move.from.file != move.to.file,
              board[move.to] == nil,
              move.to == enPassantTarget else {
            return nil
        }

        let direction = pawn.color == .white ? -1 : 1
        return Square(
            file: move.to.file,
            rank: move.to.rank + direction
        )
    }

    
    private func handleAIMoveIfNeeded() {
        guard playAgainstAI else { return }
        guard sideToMove == .black else { return }

        makeAIMove()
    }

    
//    func makeMove(_ move: Move) {
//        guard let piece = board[move.from] else { return }
//        let movingPiece = piece
//        if board[move.to] != nil {
//            lastCapturedSquare = move.to
//        }
//        
//       withAnimation(.easeInOut(duration: 0.25)) {
//            
//            updateCastlingRights(piece: piece, from: move.from)
//            
//            // Castling rook move
//            if piece.type == .king, abs(move.from.file - move.to.file) == 2 {
//                moveRookForCastling(kingMove: move)
//            }
//            
//            board[move.from] = nil
//            board[move.to] = movingPiece
//            lastMove = move
//            sideToMove = sideToMove.opponent
//        }
//        
//        // 👇 AFTER animation
//        if piece.type == .pawn && (move.to.rank == 7 || move.to.rank == 0) {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
//                print("🔥 Setting pendingPromotion at \(move.to)")
//                self.pendingPromotion = PromotionRequest(
//                    square: move.to,
//                    color: piece.color
//                )
//            }
//        }
//        
//        checkForGameEnd()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//            self.lastCapturedSquare = nil
//        }
//    }
    
    func attemptMove(from: Square, to: Square) {
        let moves = legalMoves(from: from)
        guard let move = moves.first(where: { $0.to == to }) else { return }

        submitMove(move)
    }

    func legalMoves(from square: Square) -> [Move] {
        guard let piece = board[square],
              piece.color == sideToMove else { return [] }

        var moves = board.legalMoves(from: square, piece: piece, enPassantTarget: enPassantTarget)

        // Only for pawns
        if piece.type == .pawn {
            var promotionMoves: [Move] = []

            for move in moves {
                let targetRank = move.to.rank
                if targetRank == 7 || targetRank == 0 {
                    let promotionPiece: PieceType = .queen
                    // Pawn reached last rank → promotion
                    // For Phase 1 we auto-promote to queen
                    promotionMoves.append(Move(from: move.from, to: move.to, promotion: promotionPiece))
                } else {
                    promotionMoves.append(move)
                }
            }

            moves = promotionMoves
        }
        
        // Inject castling moves ONLY for kings
        if piece.type == .king {
            moves.append(contentsOf: castlingMoves(from: square, piece: piece))
        }

        // 🔍 DEBUG SANITY CHECK (temporary)
        if piece.type == .pawn {
            print("Legal moves for pawn at \(square):")
            for move in moves {
                print(
                    "→ \(move.from) → \(move.to), promotion: \(String(describing: move.promotion))"
                )
            }
        }
        return moves
    }

    private func rookCastlingMoveIfNeeded(
        _ move: Move,
        _ piece: Piece
    ) -> (from: Square, to: Square)? {

        guard piece.type == .king else { return nil }

        let fileDelta = move.to.file - move.from.file
        guard abs(fileDelta) == 2 else { return nil }

        let rank = move.from.rank

        if fileDelta == 2 {
            // King-side castling
            return (
                from: Square(file: 7, rank: rank),
                to: Square(file: 5, rank: rank)
            )
        } else {
            // Queen-side castling
            return (
                from: Square(file: 0, rank: rank),
                to: Square(file: 3, rank: rank)
            )
        }
    }

    private func castlingMoves(
        from square: Square,
        piece: Piece
    ) -> [Move] {

        guard piece.type == .king else { return [] }
        guard !board.isKingInCheck(color: piece.color, enPassantTarget: enPassantTarget) else { return [] }

        let rank = piece.color == .white ? 0 : 7
        guard square == Square(file: 4, rank: rank) else { return [] }

        var moves: [Move] = []

        if piece.color == .white {
            if castlingRights.whiteKingSide && canCastleKingSide(color: .white) {
                moves.append(Move(from: square, to: Square(file: 6, rank: rank)))
            }
            if castlingRights.whiteQueenSide && canCastleQueenSide(color: .white) {
                moves.append(Move(from: square, to: Square(file: 2, rank: rank)))
            }
        } else {
            if castlingRights.blackKingSide && canCastleKingSide(color: .black) {
                moves.append(Move(from: square, to: Square(file: 6, rank: rank)))
            }
            if castlingRights.blackQueenSide && canCastleQueenSide(color: .black) {
                moves.append(Move(from: square, to: Square(file: 2, rank: rank)))
            }
        }

        return moves
    }

    private func canCastleKingSide(color: PieceColor) -> Bool {
        let rank = color == .white ? 0 : 7
        let squares = [
            Square(file: 5, rank: rank),
            Square(file: 6, rank: rank)
        ]

        return squares.allSatisfy {
            board[$0] == nil &&
            !board.wouldSquareBeAttacked($0, by: color.opponent, enPassantTarget: enPassantTarget)
        }
    }

    private func canCastleQueenSide(color: PieceColor) -> Bool {
        let rank = color == .white ? 0 : 7
        let squares = [
            Square(file: 1, rank: rank),
            Square(file: 2, rank: rank),
            Square(file: 3, rank: rank)
        ]

        return squares.allSatisfy {
            board[$0] == nil &&
            !board.wouldSquareBeAttacked($0, by: color.opponent, enPassantTarget: enPassantTarget)
        }
    }

    func makeAIMove() {
        guard playAgainstAI else { return }
        guard sideToMove == .black else { return }
        guard gameResult == nil else { return }
        guard let move = ai.selectMove(board: board, color: sideToMove) else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.submitMove(move)
        }
    }

    func checkForGameEnd() {
        print("---- GAME STATE CHECK ----")
        print("Side to move:", sideToMove)
        print("In check:", board.isKingInCheck(color: sideToMove, enPassantTarget: nil))
        print("Has legal moves:", board.hasAnyLegalMoves(for: sideToMove, enPassantTarget: enPassantTarget))

        if board.isCheckmate(for: sideToMove) {
            print("CHECKMATE detected")
            stopClock()
            gameResult = .checkmate(winner: sideToMove.opponent)
        } else if board.isStalemate(for: sideToMove) {
            print("STALEMATE detected")
            stopClock()
            gameResult = .stalemate
        }
        else if halfMoveClock >= 100 {
            print("DRAW by 50 detected")
            gameResult = .drawByFiftyMoveRule
            return
        }
        else if positionCounts[currentPositionKey(), default: 0] >= 3 {
            print("DRAW by Threefold Repetition")
            gameResult = .drawByThreefoldRepetition
            return
        }

    }
    
    func resetGame() {
        board = .standard()
        sideToMove = .white
        selectedSquare = nil
        gameResult = nil

        castlingRights = CastlingRights()
        enPassantTarget = nil
        pendingPromotion = nil

        lastMove = nil
        lastCapturedSquare = nil

        moveHistory.removeAll()
        gameStarted = false
        
        clock = ChessClock(whiteTime: timeControl.seconds, blackTime: timeControl.seconds)
//        startClock()
        
#if DEBUG
        //loadStalemateTestPosition()
        //loadCheckmateTestPosition()
//        loadUnsafeMoveTestPosition()
//        loadPromotionTestPosition()
//        loadCastlingTest()
#endif

    }
    
    func undoTurn() {
        if playAgainstAI {
            // Undo AI move first (if present)
            if sideToMove == .white {
                undoLastMove()
            }

            // Undo human move
            undoLastMove()
        } else {
//            undoLastMove()
            clearStagedMove()
            stagedMove = nil
        }
    }

    func undoLastMove() {
        guard !isThinking else { return }
        guard let record = moveHistory.popLast() else { return }

        let move = record.move

        withAnimation(.easeInOut(duration: 0.25)) {

            board[move.from] = record.movedPiece
            board[move.to] = record.capturedPiece

            if let rookMove = record.rookMove {
                let rook = board[rookMove.to]
                board[rookMove.to] = nil
                board[rookMove.from] = rook
            }

            castlingRights = record.previousCastlingRights
            sideToMove = record.previousSideToMove
            gameResult = record.previousGameResult
            halfMoveClock = record.previousHalfMoveClock
            previousPositionCounts = record.previousPositionCounts
            previousEnPassantTarget = record.previousEnPassantTarget
            lastMove = nil
        }
    }

    func undo(toMoveIndex index: Int) {
        guard !isThinking else { return }
        guard index >= 0 else { return }

        while moveHistory.count > index + 1 {
            undoLastMove()
        }
    }

    func loadPromotionTestPosition() {
        setBoard(.promotionTestPosition())
        sideToMove = .white
        selectedSquare = Square(file: 4, rank: 6)
        gameResult = nil
    }

    func loadCheckmateTestPosition() {
        board = .checkmateInOneTestPosition()
        sideToMove = .white
        selectedSquare = Square(file: 6, rank: 5)
        gameResult = nil
    }

    func loadStalemateTestPosition() {
        board = .stalemateTestPosition()
        sideToMove = .white
        selectedSquare = nil
        gameResult = nil
    }

    func loadUnsafeMoveTestPosition() {
        board = .unsafeMoveTestPosition()
        sideToMove = .black
        selectedSquare = nil
        gameResult = nil
    }

    func loadCastlingTest() {
        board = .whiteKingSideCastleTestPosition()
//        board = .whiteQueenSideCastleTestPosition()
//        board = .castlingThroughCheckTestPosition()
        castlingRights = CastlingRights() // all true
        sideToMove = .white
        selectedSquare = Square(file: 4, rank: 0)
        gameResult = nil
    }
    
    func loadEnPassantTestPosition() {
        setBoard(.enPassantTestPosition())
        sideToMove = .white
        gameResult = nil

        // Critical: mark en-passant target square (d6)
        enPassantTarget = Square(file: 3, rank: 5)
        selectedSquare = Square(file: 4, rank: 4)
    }

    
    func updateRookCastlingRights(from square: Square, color: PieceColor) {
        if color == .white {
            if square == Square(file: 0, rank: 0) {
                castlingRights.whiteQueenSide = false
            }
            if square == Square(file: 7, rank: 0) {
                castlingRights.whiteKingSide = false
            }
        } else {
            if square == Square(file: 0, rank: 7) {
                castlingRights.blackQueenSide = false
            }
            if square == Square(file: 7, rank: 7) {
                castlingRights.blackKingSide = false
            }
        }
    }

    private func updateCastlingRights(
        piece: Piece,
        from square: Square
    ) {
        if piece.type == .king {
            if piece.color == .white {
                castlingRights.whiteKingSide = false
                castlingRights.whiteQueenSide = false
            } else {
                castlingRights.blackKingSide = false
                castlingRights.blackQueenSide = false
            }
        }

        if piece.type == .rook {
            if piece.color == .white {
                if square == Square(file: 0, rank: 0) {
                    castlingRights.whiteQueenSide = false
                }
                if square == Square(file: 7, rank: 0) {
                    castlingRights.whiteKingSide = false
                }
            } else {
                if square == Square(file: 0, rank: 7) {
                    castlingRights.blackQueenSide = false
                }
                if square == Square(file: 7, rank: 7) {
                    castlingRights.blackKingSide = false
                }
            }
        }
    }

    private func moveRookForCastling(kingMove: Move) {
        let rank = kingMove.from.rank

        if kingMove.to.file == 6 {
            // King side
            let rookFrom = Square(file: 7, rank: rank)
            let rookTo = Square(file: 5, rank: rank)

            if let rook = board[rookFrom] {
                board[rookFrom] = nil
                board[rookTo] = rook
            }
        } else if kingMove.to.file == 2 {
            // Queen side
            let rookFrom = Square(file: 0, rank: rank)
            let rookTo = Square(file: 3, rank: rank)

            if let rook = board[rookFrom] {
                board[rookFrom] = nil
                board[rookTo] = rook
            }
        }
    }

    func promotePawn(at square: Square, to type: PieceType) {
        guard let pawn = board[square], pawn.type == .pawn else { return }
        board[square] = Piece(type: type, color: pawn.color)
        pendingPromotion = nil
    }

    func currentPositionKey() -> PositionKey {
        PositionKey(
            boardHash: board.positionHash(),
            sideToMove: sideToMove,
            castlingRights: castlingRights
        )
    }
    
    func startClock() {
        stopClock()

        clock.isRunning = true

        clockTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, self.clock.isRunning else { return }

            switch self.sideToMove {
            case .white:
                self.clock.whiteTime -= 1
                if self.clock.whiteTime <= 0 {
                    self.handleTimeLoss(for: .white)
                }
            case .black:
                self.clock.blackTime -= 1
                if self.clock.blackTime <= 0 {
                    self.handleTimeLoss(for: .black)
                }
            }
        }
    }


    func stopClock() {
        clockTimer?.invalidate()
        clockTimer = nil
        clock.isRunning = false
    }

    func switchClock() {
        // Nothing fancy yet — ticking depends on sideToMove
    }

    func handleTimeLoss(for color: PieceColor) {
        stopClock()
        gameResult = .timeout(winner: color.opponent)
    }

}

