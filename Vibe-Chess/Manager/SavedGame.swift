//
//  SavedGame.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 15.01.26.
//

import Foundation

struct SavedGame: Codable, Identifiable {
    let id: UUID
    let name: String
    let date: Date

    let board: Board
    let sideToMove: PieceColor
    let castlingRights: CastlingRights
    let moveHistory: [MoveRecord]
    let whiteTime: TimeInterval
    let blackTime: TimeInterval
    let playAgainstAI: Bool
}
