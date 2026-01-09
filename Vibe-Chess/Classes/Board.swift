//
//  Board.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 30.12.25.
//

import Foundation

let knightOffsets = [
    (1, 2), (2, 1), (2, -1), (1, -2),
    (-1, -2), (-2, -1), (-2, 1), (-1, 2)
]

let rookDirections = [
    (1, 0), (-1, 0), (0, 1), (0, -1)
]

let bishopDirections = [
    (1, 1), (1, -1), (-1, 1), (-1, -1)
]


struct Board: Codable, Equatable {
    private(set) var squares: [Piece?] = Array(repeating: nil, count: 64)

    subscript(_ square: Square) -> Piece? {
        get {
            squares[square.rank * 8 + square.file]
        }
        set {
            squares[square.rank * 8 + square.file] = newValue
        }
    }
}

extension Board {
    static func standard() -> Board {
        var board = Board()

        let backRank: [PieceType] =
            [.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook]

        for file in 0..<8 {
            board[Square(file: file, rank: 1)] = Piece(type: .pawn, color: .white)
            board[Square(file: file, rank: 6)] = Piece(type: .pawn, color: .black)

            board[Square(file: file, rank: 0)] =
                Piece(type: backRank[file], color: .white)
            board[Square(file: file, rank: 7)] =
                Piece(type: backRank[file], color: .black)
        }

        return board
    }
}

extension Board {
    func pseudoLegalMoves(
        from square: Square,
        piece: Piece,
        enPassantTarget: Square?
    ) -> [Move] {

        switch piece.type {
        case .pawn:
            return pawnMoves(from: square, piece: piece, enPassantTarget: enPassantTarget )
        case .knight:
            return knightMoves(from: square, piece: piece)
        case .bishop:
            return slidingMoves(from: square, piece: piece, directions: bishopDirections)
        case .rook:
            return slidingMoves(from: square, piece: piece, directions: rookDirections)
        case .queen:
            return slidingMoves(
                from: square,
                piece: piece,
                directions: bishopDirections + rookDirections
            )
        case .king:
            return kingMoves(from: square, piece: piece)
        }
    }
}

extension Board {
    func pawnMoves(from square: Square, piece: Piece, enPassantTarget: Square?) -> [Move] {
        var moves: [Move] = []

        let direction = piece.color == .white ? 1 : -1
        let startRank = piece.color == .white ? 1 : 6

        let oneForward = square + (0, direction)
        if oneForward.isValid && self[oneForward] == nil {
            moves.append(Move(from: square, to: oneForward))

            let twoForward = square + (0, 2 * direction)
            if square.rank == startRank && self[twoForward] == nil {
                moves.append(Move(from: square, to: twoForward))
            }
        }

        for fileOffset in [-1, 1] {
            let capture = square + (fileOffset, direction)
            if capture.isValid,
               let target = self[capture],
               target.color != piece.color {
                moves.append(Move(from: square, to: capture))
            }
        }

        // En passant
        if let epSquare = enPassantTarget {
            let direction = piece.color == .white ? 1 : -1

            if epSquare.rank == square.rank + direction &&
               abs(epSquare.file - square.file) == 1 {

                moves.append(
                    Move(from: square, to: epSquare)
                )
            }
        }
        
        return moves
    }
}

extension Board {
    func knightMoves(from square: Square, piece: Piece) -> [Move] {
        knightOffsets.compactMap { offset in
            let target = square + offset
            guard target.isValid else { return nil }

            if let other = self[target], other.color == piece.color {
                return nil
            }
            return Move(from: square, to: target)
        }
    }
}

extension Board {
    func slidingMoves(
        from square: Square,
        piece: Piece,
        directions: [(Int, Int)]
    ) -> [Move] {

        var moves: [Move] = []

        for dir in directions {
            var current = square + dir
            while current.isValid {
                if let blocker = self[current] {
                    if blocker.color != piece.color {
                        moves.append(Move(from: square, to: current))
                    }
                    break
                }
                moves.append(Move(from: square, to: current))
                current = current + dir
            }
        }

        return moves
    }
}

extension Board {
    func standardKingMoves(from square: Square, piece: Piece) -> [Move] {
        var moves: [Move] = []

        for dx in -1...1 {
            for dy in -1...1 where !(dx == 0 && dy == 0) {
                let target = square + (dx, dy)
                guard target.isValid else { continue }

                if let other = self[target], other.color == piece.color {
                    continue
                }
                moves.append(Move(from: square, to: target))
            }
        }
        return moves
    }
    
    func kingMoves(from square: Square, piece: Piece) -> [Move] {
        var moves: [Move] = []

        for dx in -1...1 {
            for dy in -1...1 where !(dx == 0 && dy == 0) {
                let target = square + (dx, dy)
                guard target.isValid else { continue }

                if let other = self[target], other.color == piece.color {
                    continue
                }

                moves.append(Move(from: square, to: target))
            }
        }

        return moves
    }

}

extension Board {
    func isKingInCheck(color: PieceColor,enPassantTarget: Square?) -> Bool {
        guard let kingSquare = squares.indices
            .compactMap({ index -> Square? in
                let piece = squares[index]
                if piece?.type == .king && piece?.color == color {
                    return Square(file: index % 8, rank: index / 8)
                }
                return nil
            })
            .first else { return false }

        for index in squares.indices {
            guard let piece = squares[index],
                  piece.color != color else { continue }

            let from = Square(file: index % 8, rank: index / 8)
            let moves = pseudoLegalMoves(from: from, piece: piece,enPassantTarget: enPassantTarget)

            if moves.contains(where: { $0.to == kingSquare }) {
                return true
            }
        }
        return false
    }
}

extension Board {
    func legalMoves(
        from square: Square,
        piece: Piece,
        enPassantTarget: Square?
    ) -> [Move] {

        pseudoLegalMoves(from: square, piece: piece,enPassantTarget:enPassantTarget).filter { move in
            var copy = self
            copy[move.from] = nil
            copy[move.to] = piece
            return !copy.isKingInCheck(color: piece.color, enPassantTarget: enPassantTarget)
        }
    }
}

extension Board {
    func legalMoves(for color: PieceColor,enPassantTarget:Square?) -> [Move] {
        var result: [Move] = []

        for index in squares.indices {
            guard let piece = squares[index],
                  piece.color == color else { continue }

            let square = Square(file: index % 8, rank: index / 8)
            result.append(contentsOf: legalMoves(from: square, piece: piece, enPassantTarget: enPassantTarget))
        }

        return result
    }
}

extension Board {
    func applying(_ move: Move) -> Board {
        var copy = self
        if let piece = copy[move.from] {
            copy[move.from] = nil
            copy[move.to] = piece
        }
        return copy
    }
}

extension Board {
    func hasAnyLegalMoves(for color: PieceColor,enPassantTarget: Square?) -> Bool {
        for index in squares.indices {
            guard let piece = squares[index],
                  piece.color == color else { continue }

            let square = Square(file: index % 8, rank: index / 8)
            if !legalMoves(from: square, piece: piece, enPassantTarget: enPassantTarget).isEmpty {
                return true
            }
        }
        return false
    }
}

extension Board {
    func isCheckmate(for color: PieceColor) -> Bool {
        isKingInCheck(color: color, enPassantTarget: nil) && !hasAnyLegalMoves(for: color, enPassantTarget: nil)
    }

    func isStalemate(for color: PieceColor) -> Bool {
        !isKingInCheck(color: color, enPassantTarget: nil) && !hasAnyLegalMoves(for: color, enPassantTarget: nil)
    }
}

func findCheckmateInOne(
    board: Board,
    color: PieceColor
) -> Move? {

    let moves = board.legalMoves(for: color,enPassantTarget: nil)

    for move in moves {
        let newBoard = board.applying(move)
        if newBoard.isCheckmate(for: color.opponent) {
            return move
        }
    }
    return nil
}

extension Board {
    static func checkmateInOneTestPosition() -> Board {
        var board = Board()

        board[Square(file: 7, rank: 5)] = Piece(type: .king, color: .white)   // g6
        board[Square(file: 6, rank: 5)] = Piece(type: .queen, color: .white)  // g7
        board[Square(file: 7, rank: 7)] = Piece(type: .king, color: .black)   // h8

        return board
    }
}

extension Board {
    static func stalemateTestPosition() -> Board {
        var board = Board()

        board[Square(file: 2, rank: 5)] = Piece(type: .king, color: .white)   // c6
        board[Square(file: 2, rank: 6)] = Piece(type: .queen, color: .white)  // c7
        board[Square(file: 0, rank: 7)] = Piece(type: .king, color: .black)   // a8

        return board
    }
}

extension Board {
    static func unsafeMoveTestPosition() -> Board {
        var board = Board()

        // White
        board[Square(file: 7, rank: 5)] = Piece(type: .king, color: .white)   // h6
        board[Square(file: 6, rank: 0)] = Piece(type: .queen, color: .white)  // g1
        board[Square(file: 6, rank: 1)] = Piece(type: .pawn, color: .white)   // g2

        // Black
        board[Square(file: 7, rank: 7)] = Piece(type: .king, color: .black)   // h8
        board[Square(file: 6, rank: 7)] = Piece(type: .queen, color: .black)  // g8

        return board
    }
    
    func wouldSquareBeAttacked(
        _ square: Square,
        by attacker: PieceColor,
        enPassantTarget: Square?
    ) -> Bool {

        for index in squares.indices {
            guard let piece = squares[index],
                  piece.color == attacker else { continue }

            let from = Square(file: index % 8, rank: index / 8)

            if piece.type == .pawn {
                let dir = piece.color == .white ? 1 : -1
                let attacks = [
                    from + (-1, dir),
                    from + (1, dir)
                ]
                if attacks.contains(square) {
                    return true
                }
                continue
            }

            let moves = pseudoLegalMoves(from: from, piece: piece, enPassantTarget: enPassantTarget)

            if moves.contains(where: { $0.to == square }) {
                return true
            }
        }

        return false
    }

}

extension Board {

    static func promotionTestPosition() -> Board {
        var board = Board()

        // Clear everything first
        board.squares = Array(repeating: nil, count: 64)

        // Pawns ready to promote
        board[Square(file: 4, rank: 6)] = Piece(type: .pawn, color: .white) // e7
        board[Square(file: 4, rank: 1)] = Piece(type: .pawn, color: .black) // e7

        // Kings must exist but NOT block promotion
        board[Square(file: 0, rank: 0)] = Piece(type: .king, color: .white)
        board[Square(file: 7, rank: 7)] = Piece(type: .king, color: .black)

        return board
    }
}

extension Board {
    static func whiteKingSideCastleTestPosition() -> Board {
        var board = Board()
        board.squares = Array(repeating: nil, count: 64)

        // Kings
        board[Square(file: 4, rank: 0)] = Piece(type: .king, color: .white)
        board[Square(file: 4, rank: 7)] = Piece(type: .king, color: .black)

        // Rook for castling
        board[Square(file: 7, rank: 0)] = Piece(type: .rook, color: .white)
        board[Square(file: 0, rank: 0)] = Piece(type: .rook, color: .white)

        return board
    }
}

extension Board {
    static func whiteQueenSideCastleTestPosition() -> Board {
        var board = Board()
        board.squares = Array(repeating: nil, count: 64)

        board[Square(file: 4, rank: 0)] = Piece(type: .king, color: .white)
        board[Square(file: 4, rank: 7)] = Piece(type: .king, color: .black)

        board[Square(file: 0, rank: 0)] = Piece(type: .rook, color: .white)

        return board
    }
}

extension Board {
    static func castlingThroughCheckTestPosition() -> Board {
        var board = Board()
        board.squares = Array(repeating: nil, count: 64)

        board[Square(file: 4, rank: 0)] = Piece(type: .king, color: .white)
        board[Square(file: 7, rank: 0)] = Piece(type: .rook, color: .white)

        board[Square(file: 4, rank: 7)] = Piece(type: .king, color: .black)

        // Black rook attacking f1
        board[Square(file: 5, rank: 7)] = Piece(type: .rook, color: .black)

        return board
    }
    
    func positionHash() -> String {
        squares.enumerated()
            .map { index, piece in
                if let piece {
                    return "\(piece.color.rawValue)\(piece.type.rawValue)\(index)"
                } else {
                    return "._"
                }
            }
            .joined(separator: "|")
    }

}

extension Board {

    static func enPassantTestPosition() -> Board {
        var board = Board()
        board.squares = Array(repeating: nil, count: 64)

        // White pawn on e5
        board[Square(file: 4, rank: 4)] = Piece(type: .pawn, color: .white)

        // Black pawn that just advanced two squares: d7 → d5
        board[Square(file: 3, rank: 4)] = Piece(type: .pawn, color: .black)

        // Kings (required for legality)
        board[Square(file: 4, rank: 0)] = Piece(type: .king, color: .white)
        board[Square(file: 4, rank: 7)] = Piece(type: .king, color: .black)

        return board
    }
}


extension Board {

    func findAmbiguousPieces(
        for piece: Piece,
        movingTo target: Square
    ) -> [AmbiguousPiece] {

        var result: [AmbiguousPiece] = []

        for index in squares.indices {
            guard let other = squares[index] else { continue }

            // Same type & color
            guard other.type == piece.type,
                  other.color == piece.color else { continue }

            let from = Square(file: index % 8, rank: index / 8)

            // Skip the piece that is actually moving
            if from == target { continue }

            // Can THIS piece also move to the target?
            let legalMoves = legalMoves(from: from, piece: other, enPassantTarget: nil)

            if legalMoves.contains(where: { $0.to == target }) {
                result.append(AmbiguousPiece(from: from))
            }
        }

        return result
    }
}
