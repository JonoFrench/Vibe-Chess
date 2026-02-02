//
//  SquareView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 30.12.25.
//

import Foundation
import SwiftUI

struct SquareView: View {
    @EnvironmentObject var manager: GameManager
    
    let piece: Piece?
    let size: CGFloat
    let square: Square?
    let namespace: Namespace.ID
    var body: some View {
        ZStack {
            if let piece, let square {
                Image(piece.imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.1)
                    .id(piece.version)
                    .rotationEffect(rotation(for: piece))
                    .rotationEffect(boardRotation(for: piece))
                    .matchedGeometryEffect(
                        id: piece.id,
                        in: namespace,
                        properties: .position
                    )
                    .allowsHitTesting(false)
                if manager.lastCapturedSquare == square {
                    Image(piece.imageName)
                        .resizable()
                        .scaleEffect(1.2)
                        .opacity(0)
                        .animation(.easeOut(duration: 0.2), value: manager.lastCapturedSquare)
                        .allowsHitTesting(false)
                }
                
            }
        }.frame(width: size, height: size)
    }
    
    private func rotation(for piece: Piece) -> Angle {
            guard manager.playFace2Face,
                  piece.color == .black else {
                return .degrees(0)
            }
            return .degrees(180)
        }
    
    private func boardRotation(for piece: Piece) -> Angle {
        guard !manager.playFace2Face, !manager.playAgainstAI,
              manager.sideToMove == .black else {
                return .degrees(0)
            }
            return .degrees(180)
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
