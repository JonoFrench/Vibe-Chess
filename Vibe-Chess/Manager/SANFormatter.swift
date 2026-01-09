//
//  SANFormatter.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 7.01.26.
//

import Foundation

struct SANFormatter {

    static func san(for record: MoveRecord) -> String {
        let move = record.move
        let piece = record.movedPiece
        let isCapture = record.capturedPiece != nil

        // Castling
        if piece.type == .king {
            let fileDiff = abs(move.from.file - move.to.file)
            if fileDiff == 2 {
                return move.to.file == 6 ? "O-O" : "O-O-O"
            }
        }

        let pieceLetter: String = {
            switch piece.type {
            case .king: return "K"
            case .queen: return "Q"
            case .rook: return "R"
            case .bishop: return "B"
            case .knight: return "N"
            case .pawn: return ""
            }
        }()

        let capture = isCapture ? "x" : ""
        let destination = move.to.algebraic

        // Pawn capture needs file
        let pawnPrefix =
            piece.type == .pawn && isCapture
            ? String(UnicodeScalar(97 + move.from.file)!)
            : ""

        // Promotion
        if let promotion = record.promotion {
            return "\(pawnPrefix)\(capture)\(destination)=\(promotion.algebraic)"
        }

        return "\(pieceLetter)\(pawnPrefix)\(capture)\(destination)"
    }
}
