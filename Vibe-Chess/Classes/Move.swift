//
//  Move.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 30.12.25.
//

import Foundation

struct Move: Hashable, Codable {
    let from: Square
    let to: Square
    var promotion: PieceType? = nil
}

struct RookMove: Codable, Equatable {
    let from: Square
    let to: Square
}

struct MoveRecord: Codable, Identifiable {
    let id = UUID()
    
    let move: Move

    let movedPiece: Piece
    let capturedPiece: Piece?

    let previousCastlingRights: CastlingRights
    let previousSideToMove: PieceColor
    let previousGameResult: GameResult?
    let previousHalfMoveClock: Int
    let previousPositionCounts: [PositionKey: Int]
    let previousEnPassantTarget: Square?

    // Castling
    let rookMove: RookMove?

    // Promotion
    let promotion: PieceType?
    
    let isCheck: Bool
    let isCheckmate: Bool
    
    let disambiguationFile: Bool
    let disambiguationRank: Bool

//    let previousClock: ChessClock

}

extension MoveRecord {

    func sanString() -> String {

        // Castling
        if let rookMove {
            let castle = rookMove.to.file == 5 ? "O-O" : "O-O-O"
            return castle + suffix
        }

        var san = ""

        // Piece letter
        if movedPiece.type != .pawn {
            san += movedPiece.type.algebraic
        }

        // Disambiguation
        if disambiguationFile {
            san += fromFile
        }
        if disambiguationRank {
            san += fromRank
        }

        // Capture
        if capturedPiece != nil {
            if movedPiece.type == .pawn && !disambiguationFile {
                san += fromFile
            }
            san += "x"
        }

        // Destination
        san += move.to.algebraic

        // Promotion
        if let promotion {
            san += "=\(promotion.algebraic)"
        }

        // Check / mate
        san += suffix

        return san
    }

    private var suffix: String {
        if isCheckmate { return "#" }
        if isCheck { return "+" }
        return ""
    }

    private var fromFile: String {
        String(UnicodeScalar(97 + move.from.file)!)
    }

    private var fromRank: String {
        "\(move.from.rank + 1)"
    }
}

