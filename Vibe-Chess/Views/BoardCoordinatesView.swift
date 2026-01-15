//
//  BoardCoordinatesView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 9.01.26.
//

import SwiftUI

struct BoardCoordinatesLayer: View {
    @EnvironmentObject var manager: GameManager

    let boardSize: CGFloat
    let padding: CGFloat

    private let files = ["a","b","c","d","e","f","g","h"]

    var body: some View {
        ZStack {
            // Files (bottom)
            ForEach(0..<8, id: \.self) { file in
                Text(files[file])
                    .font(.caption)
                    .foregroundColor(.white)
                    .position(
                        x: padding + CGFloat(file) * squareSize + 6,
                        y: boardSize + 8
                    )
                if manager.rotateBlackPieces {
                    Text(files[file])
                        .font(.caption)
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(180))
                        .position(
                            x: padding + CGFloat(file) * squareSize + 6,
                            y: -8
                        )
                }
            }

            // Ranks (left)
            ForEach(0..<8, id: \.self) { rank in
                Text("\(rank + 1)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .position(
                        x: -8,
                        y: boardSize - (CGFloat(rank) * squareSize + squareSize / 2)
                    )
                if manager.rotateBlackPieces {                    
                    Text("\(rank + 1)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(180))
                        .position(
                            x: boardSize + padding - 8 ,
                            y: boardSize - (CGFloat(rank) * squareSize + squareSize / 2)
                        )
                }
            }
        }
        .allowsHitTesting(false)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: manager.showCoordinates)
    }

    private var squareSize: CGFloat {
        boardSize / 8
    }
}

