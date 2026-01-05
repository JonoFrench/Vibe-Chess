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
}

@MainActor
final class GameManager: ObservableObject {
    
    @Published private(set) var board = Board.standard()
    @Published private(set) var sideToMove: PieceColor = .white
    @Published var selectedSquare: Square? = nil
    @Published private(set) var gameResult: GameResult? = nil
    @Published var lastCapturedSquare: Square? = nil
    @Published var lastMove: Move? = nil

    private let ai = SimpleChessAI()
    var playAgainstAI = true
    var squareDimension = 0.0
    
    init() {
        if UIDevice.current.userInterfaceIdiom == .pad {
        } else {
            
        }
#if DEBUG
        //loadStalemateTestPosition()
        //loadCheckmateTestPosition()
//        loadUnsafeMoveTestPosition()
#endif
        
    }
    
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
    
    func makeMove(_ move: Move) {
        guard let piece = board[move.from] else { return }
        if board[move.to] != nil {
            lastCapturedSquare = move.to
        }
        withAnimation(.easeInOut(duration: 0.25)) {
            board[move.from] = nil
            board[move.to] = piece
            lastMove = move
            sideToMove = sideToMove.opponent
        }

        checkForGameEnd()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.lastCapturedSquare = nil
        }
    }
    
    
    func attemptMove(from: Square, to: Square) {
        let moves = legalMoves(from: from)
        guard moves.contains(where: { $0.to == to }) else { return }
        
        let piece = board[from]!
        withAnimation(.easeInOut(duration: 0.25)) {
            board[from] = nil
            board[to] = piece
            sideToMove = sideToMove.opponent
        }
        checkForGameEnd()
        // AI response
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            if self.playAgainstAI && self.sideToMove == .black {
                self.makeAIMove()
            }
        }
    }
    
    func legalMoves(from square: Square) -> [Move] {
        guard let piece = board[square],
              piece.color == sideToMove else { return [] }
        
        return board.legalMoves(from: square, piece: piece)
    }
    
    func makeAIMove() {
        guard let move = ai.selectMove(board: board, color: sideToMove) else {
            return
        }
        
        // Small delay = nicer UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.makeMove(move)
        }
    }
    
    func checkForGameEnd() {
        print("---- GAME STATE CHECK ----")
        print("Side to move:", sideToMove)
        print("In check:", board.isKingInCheck(color: sideToMove))
        print("Has legal moves:", board.hasAnyLegalMoves(for: sideToMove))

        if board.isCheckmate(for: sideToMove) {
            print("CHECKMATE detected")
            gameResult = .checkmate(winner: sideToMove.opponent)
        } else if board.isStalemate(for: sideToMove) {
            print("STALEMATE detected")
            gameResult = .stalemate
        }
    }

    
//    func checkForGameEnd() {
//        if board.isCheckmate(for: sideToMove) {
//            gameResult = .checkmate(winner: sideToMove.opponent)
//        } else if board.isStalemate(for: sideToMove) {
//            gameResult = .stalemate
//        }
//        print("Black in check:", board.isKingInCheck(color: .black))
//        print("Black has moves:", board.hasAnyLegalMoves(for: .black))
//
//    }
    
    func resetGame() {
        board = .standard()
        sideToMove = .white
        selectedSquare = nil
        gameResult = nil
    }
    
    func loadCheckmateTestPosition() {
        board = .checkmateInOneTestPosition()
        sideToMove = .white
        selectedSquare = nil
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

}

