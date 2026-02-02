//
//  Piece.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 30.12.25.
//

import Foundation
import SwiftUI

enum PieceColor: Int, Codable {
    case white
    case black
    
    var opponent: PieceColor {
        self == .white ? .black : .white
    }
}

enum PieceType: Int, Codable {
    case king, queen, rook, bishop, knight, pawn
    
    var algebraic: String {
        switch self {
        case .king: return "K"
        case .queen: return "Q"
        case .rook: return "R"
        case .bishop: return "B"
        case .knight: return "N"
        default: return ""
        }
    }
}

extension PieceColor {
    var displayName: String {
        self == .white ? "White" : "Black"
    }
}


struct Piece: Codable, Equatable, Identifiable {
    let id: UUID
    let type: PieceType
    let color: PieceColor
    var version: Int
    
    init(type: PieceType, color: PieceColor, id: UUID = UUID()) {
        self.id = id
        self.type = type
        self.color = color
        self.version = 0
    }
}

extension Piece {
    var imageName: String {
        "\(color)_\(type)"
    }
}

struct AmbiguousPiece {
    let from: Square
}
