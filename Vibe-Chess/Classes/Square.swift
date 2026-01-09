//
//  Square.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 30.12.25.
//

import Foundation

struct Square: Hashable, Codable {
    var file: Int   // 0–7 (a–h)
    var rank: Int   // 0–7 (1–8)
    
    var isValid: Bool {
        (0..<8).contains(file) && (0..<8).contains(rank)
    }
    
    static func +(lhs: Square, rhs: (Int, Int)) -> Square {
        Square(file: lhs.file + rhs.0, rank: lhs.rank + rhs.1)
    }
    
    var algebraic: String {
        let fileChar = String(UnicodeScalar(97 + file)!)
        return "\(fileChar)\(rank + 1)"
    }
}

