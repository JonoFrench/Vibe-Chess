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

@MainActor
final class GameManager: ObservableObject {
    
    @Published private(set) var board = Board.standard()
    @Published private(set) var sideToMove: PieceColor = .white
    @Published var selectedSquare: Square? = nil
    
    func makeMove(_ move: Move) {
        guard let piece = board[move.from] else { return }

        board[move.from] = nil
        board[move.to] = piece
        sideToMove = sideToMove.opponent
    }
    
    var squareDimension = 0.0

    init() {
        if UIDevice.current.userInterfaceIdiom == .pad {
        } else {
            
        }
    }
}

extension GameManager {
    func select(_ square: Square) {
        guard let piece = board[square] else {
            // Tap on empty square
            if let from = selectedSquare {
                attemptMove(from: from, to: square)
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
}

extension GameManager {
    func attemptMove(from: Square, to: Square) {
        let moves = legalMoves(from: from)
        guard moves.contains(where: { $0.to == to }) else { return }

        let piece = board[from]!
        board[from] = nil
        board[to] = piece
        sideToMove = sideToMove.opponent
    }
}

extension GameManager {
    func legalMoves(from square: Square) -> [Move] {
        guard let piece = board[square],
              piece.color == sideToMove else { return [] }

        return board.legalMoves(from: square, piece: piece)
    }
}

