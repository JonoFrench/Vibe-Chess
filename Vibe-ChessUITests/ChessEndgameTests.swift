//
//  ChessEndgameTests.swift
//  Vibe-ChessUITests
//
//  Created by Jonathan French on 3.01.26.
//

import Foundation
import SwiftUI
import XCTest
@testable import Vibe_Chess

@MainActor
final class ChessEndgameTests: XCTestCase {
 
    var manager: GameManager!

    override func setUpWithError() throws {
        manager = GameManager()
    }
    
    override func tearDownWithError() throws {
        manager = nil
    }

    func testCheckmateInOneDetection() {
        var board = Board()
        
        // White
        board[Square(file: 7, rank: 5)] = Piece(type: .king, color: .white)   // h6
        board[Square(file: 6, rank: 5)] = Piece(type: .queen, color: .white) // g6
        
        // Black
        board[Square(file: 7, rank: 7)] = Piece(type: .king, color: .black)  // h8
        
        // Sanity check: not already checkmate
        XCTAssertFalse(board.isCheckmate(for: .black))
        
        // White plays Qg7#
        let mateMove = Move(
            from: Square(file: 6, rank: 5),
            to: Square(file: 6, rank: 6)
        )
        
        let newBoard = board.applying(mateMove)
        
        XCTAssertTrue(newBoard.isKingInCheck(color: .black))
        XCTAssertTrue(newBoard.isCheckmate(for: .black))
    }
}

func testStalemateDetection() {
    var board = Board()
    
    // White
    board[Square(file: 2, rank: 5)] = Piece(type: .king, color: .white)   // c6
    board[Square(file: 2, rank: 6)] = Piece(type: .queen, color: .white) // c7
    
    // Black
    board[Square(file: 0, rank: 7)] = Piece(type: .king, color: .black)  // a8
    
    XCTAssertFalse(board.isKingInCheck(color: .black))
    XCTAssertFalse(board.hasAnyLegalMoves(for: .black))
    XCTAssertTrue(board.isStalemate(for: .black))
}

func testAIAvoidsMateInOne() {
    var board = Board()
    
    // White threatening Qh7#
    board[Square(file: 7, rank: 5)] = Piece(type: .king, color: .white)   // h6
    board[Square(file: 6, rank: 0)] = Piece(type: .queen, color: .white)  // g1
    board[Square(file: 6, rank: 1)] = Piece(type: .pawn, color: .white)   // g2
    
    // Black
    board[Square(file: 7, rank: 7)] = Piece(type: .king, color: .black)   // h8
    board[Square(file: 6, rank: 7)] = Piece(type: .queen, color: .black)  // g8
    
    let ai = SimpleChessAI()
    
    guard let move = ai.selectMove(board: board, color: .black) else {
        XCTFail("AI failed to select a move")
        return
    }
    
    let newBoard = board.applying(move)
    
    // White should NOT have a mate-in-1 anymore
    let whiteMoves = newBoard.legalMoves(for: .white)
    
    let whiteHasMate = whiteMoves.contains { reply in
        let replyBoard = newBoard.applying(reply)
        return replyBoard.isCheckmate(for: .black)
    }
    
    XCTAssertFalse(
        whiteHasMate,
        "AI allowed a checkmate-in-1 after move \(move)"
    )
}
