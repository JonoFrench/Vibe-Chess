//
//  SquareView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 30.12.25.
//

import Foundation
import SwiftUI

struct SquareView: View {
    let piece: Piece?
    let size: CGFloat

    var body: some View {
        ZStack {
            if let piece {
                Image(piece.imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.1)
            }
        }
        .frame(width: size, height: size)
    }
}

extension Square {
    func center(
        squareSize: CGFloat,
        boardSize: CGFloat
    ) -> CGPoint {
        CGPoint(
            x: CGFloat(file) * squareSize + squareSize / 2,
            y: boardSize - (CGFloat(rank) * squareSize + squareSize / 2)
        )
    }
}
