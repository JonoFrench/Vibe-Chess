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

struct MoveRecord {
    let move: Move

    let movedPiece: Piece
    let capturedPiece: Piece?

    let previousCastlingRights: CastlingRights
    let previousSideToMove: PieceColor
    let previousGameResult: GameResult?

    // Castling
    let rookMove: (from: Square, to: Square)?

    // Promotion
    let promotion: PieceType?
}
