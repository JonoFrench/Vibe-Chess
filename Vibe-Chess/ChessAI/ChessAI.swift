//
//  ChessAI.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 3.01.26.
//
//We could later:
//add “Very Hard (depth search)”
//add “Blitz AI” (fast but risky)
//or “Analysis mode” that shows best lines.

import Foundation

enum AIDifficulty: String, CaseIterable, Identifiable, Codable {
    case easy
    case medium
    case hard

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
}

final class SimpleChessAI {
    
    private let pieceValue: [PieceType: Int] = [
        .pawn: 100,
        .knight: 320,
        .bishop: 330,
        .rook: 500,
        .queen: 900,
        .king: 20_000
    ]
    
    func evaluate(board: Board, for color: PieceColor) -> Int {
        var score = 0
        for piece in board.squares.compactMap({ $0 }) {
            let value = pieceValue[piece.type]!
            score += (piece.color == color) ? value : -value
        }
        return score
    }

    func scoreMove(
        _ move: Move,
        board: Board,
        color: PieceColor
    ) -> Int {

        let newBoard = board.applying(move)
        var score = evaluate(board: newBoard, for: color)

        // Capture bonus
        if let captured = board[move.to] {
            score += pieceValue[captured.type]! / 2
        }

        // Penalize hanging pieces
        if newBoard.isKingInCheck(color: color, enPassantTarget: nil) {
            score -= 500
        }

        return score
    }

    func selectMove(
        board: Board,
        color: PieceColor,
        difficulty: AIDifficulty
    ) -> Move? {

        let moves = board.legalMoves(for: color, enPassantTarget: nil)
        guard !moves.isEmpty else { return nil }

        // 🔥 Priority 1: Deliver checkmate
        if let mate = findCheckmateInOne(board: board, color: color) {
            return mate
        }

        // 🛡️ Filter out moves that allow opponent mate-in-1
        let safeMoves = moves.filter { move in
                let unsafe = allowsOpponentMateInOne(
                    after: move,
                    board: board,
                    color: color
                )

                if unsafe {
                    print("AI rejects unsafe move:", move)
                }

                return !unsafe
            }
        
        let candidateMoves = safeMoves.isEmpty ? moves : safeMoves

        let scored = candidateMoves.map {
            ($0, scoreMove($0, board: board, color: color))
        }

        let sorted = scored.sorted { $0.1 > $1.1 }

        
        // ======= DIFFICULTY BEHAVIOR =======
        switch difficulty {

        case .easy:
            // Plays roughly but avoids immediate mate
            print("🤖 AI Level: EASY")
            return sorted.prefix(10).randomElement()?.0

        case .medium:
            // Your ORIGINAL behavior
            print("🤖 AI Level: MEDIUM")
            return sorted.prefix(3).randomElement()?.0

        case .hard:
            // Always pick best move
            print("🤖 AI Level: HARD")
            return sorted.first?.0
        }
    }

    func allowsOpponentMateInOne(
        after move: Move,
        board: Board,
        color: PieceColor
    ) -> Bool {

        let newBoard = board.applying(move)
        let opponent = color.opponent

        let opponentMoves = newBoard.legalMoves(for: opponent, enPassantTarget: nil)

        for reply in opponentMoves {
            let replyBoard = newBoard.applying(reply)
            if replyBoard.isCheckmate(for: color) {
                return true
            }
        }
        return false
    }

}

