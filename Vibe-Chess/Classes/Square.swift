//
//  Square.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 30.12.25.
//

import Foundation

struct Square: Hashable, Codable {
    let file: Int   // 0–7 (a–h)
    let rank: Int   // 0–7 (1–8)

    var isValid: Bool {
        (0..<8).contains(file) && (0..<8).contains(rank)
    }
}

extension Square {
    static func +(lhs: Square, rhs: (Int, Int)) -> Square {
        Square(file: lhs.file + rhs.0, rank: lhs.rank + rhs.1)
    }
}
