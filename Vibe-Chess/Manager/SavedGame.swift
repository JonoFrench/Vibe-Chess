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
    let whiteTime: TimeInterval?
    let blackTime: TimeInterval?
    let playAgainstAI: Bool
    let playFace2Face: Bool
    let aiDifficulty: AIDifficulty
    var status: GameStatus
    var result: GameResult?
    var endedAt: Date?
    var isAutoSave: Bool


    enum GameType {
        case human
        case ai
    }

    var gameType: GameType {
        playAgainstAI ? .ai : .human
    }

    var isActive: Bool {
        status == .inProgress && !isAutoSave
    }

    var isArchived: Bool {
        status == .finished
    }
}
