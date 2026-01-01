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
}

struct Piece: Codable, Equatable {
    let type: PieceType
    let color: PieceColor
}

extension Piece {
    var imageName: String {
        "\(color)_\(type)"
    }
}
