//
//  GameManagerTests.swift
//  Vibe-ChessUITests
//
//  Created by Jonathan French on 5.01.26.
//

import Foundation

// GameManagerTests.swift

import XCTest
import SwiftUI
import Combine

@testable import Vibe_Chess

@MainActor
final class GameManagerTests: XCTestCase {
    
    var manager: GameManager!
    
    override func setUpWithError() throws {
        manager = GameManager()
    }
    
    override func tearDownWithError() throws {
        manager = nil
    }
    
    func testWhiteKingSideCastling() throws {
        // Clear board except king and rook
        var board = Board()
        board[Square(file: 4, rank: 0)] = Piece(type: .king, color: .white)
        board[Square(file: 7, rank: 0)] = Piece(type: .rook, color: .white)

        manager.setBoard(board)
        manager.setCastlingRights(CastlingRights(
            whiteKingSide: true,
            whiteQueenSide: false,
            blackKingSide: false,
            blackQueenSide: false
        ))

        let legalMoves = manager.legalMoves(from: Square(file: 4, rank: 0))
        let castlingMove = Move(from: Square(file: 4, rank: 0), to: Square(file: 6, rank: 0))

        XCTAssertTrue(legalMoves.contains(castlingMove), "White king side castling should be allowed")
    }
    
    
    func testWhiteKingSideCastlingBlocked() throws {
        var board = Board()
        board[Square(file: 4, rank: 0)] = Piece(type: .king, color: .white)
        board[Square(file: 7, rank: 0)] = Piece(type: .rook, color: .white)
        // Block square f1
        board[Square(file: 5, rank: 0)] = Piece(type: .pawn, color: .white)

        manager.setBoard(board)
        manager.setCastlingRights(CastlingRights(
            whiteKingSide: true,
            whiteQueenSide: false,
            blackKingSide: false,
            blackQueenSide: false
        ))

        let legalMoves = manager.legalMoves(from: Square(file: 4, rank: 0))
        let castlingMove = Move(from: Square(file: 4, rank: 0), to: Square(file: 6, rank: 0))

        XCTAssertFalse(legalMoves.contains(castlingMove), "Castling should be blocked by piece")
    }

    func testWhiteKingSideCastlingThroughCheck() throws {
        var board = Board()
        board[Square(file: 4, rank: 0)] = Piece(type: .king, color: .white)
        board[Square(file: 7, rank: 0)] = Piece(type: .rook, color: .white)
        // Add black rook attacking f1
        board[Square(file: 5, rank: 7)] = Piece(type: .rook, color: .black)

        manager.setBoard(board)
        manager.setCastlingRights(CastlingRights(
            whiteKingSide: true,
            whiteQueenSide: false,
            blackKingSide: false,
            blackQueenSide: false
        ))

        let legalMoves = manager.legalMoves(from: Square(file: 4, rank: 0))
        let castlingMove = Move(from: Square(file: 4, rank: 0), to: Square(file: 6, rank: 0))

        XCTAssertFalse(legalMoves.contains(castlingMove), "Castling should be blocked through check")
    }

    func testBlackQueenSideCastling() throws {
        var board = Board()
        board[Square(file: 4, rank: 7)] = Piece(type: .king, color: .black)
        board[Square(file: 0, rank: 7)] = Piece(type: .rook, color: .black)

        manager.setBoard(board)
        manager.setCastlingRights(CastlingRights(
            whiteKingSide: false,
            whiteQueenSide: false,
            blackKingSide: false,
            blackQueenSide: true
        ))

        let legalMoves = manager.legalMoves(from: Square(file: 4, rank: 7))
        let castlingMove = Move(from: Square(file: 4, rank: 7), to: Square(file: 2, rank: 7))

        XCTAssertTrue(legalMoves.contains(castlingMove), "Black queen side castling should be allowed")
    }

    
}

