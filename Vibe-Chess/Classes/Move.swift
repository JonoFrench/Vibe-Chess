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
    let promotion: PieceType? = nil
}
