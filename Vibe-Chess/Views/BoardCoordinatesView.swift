//
//  BoardCoordinatesView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 9.01.26.
//

import SwiftUI

//struct BoardCoordinatesView: View {
//    @EnvironmentObject var manager: GameManager
//
//    let boardSize: CGFloat
//    let padding: CGFloat
//
//    private let files = ["a","b","c","d","e","f","g","h"]
//
//    var body: some View {
//        ZStack {
//            // Files (bottom)
//            let startX = padding + (manager.squareDimension / 2)
//            let startY = boardSize - padding - (manager.squareDimension / 2)
//            ForEach(0..<8, id: \.self) { file in
//                Text(files[file])
//                    .font(.caption )
//                    .foregroundColor(.white)
//                    .position(
//                        x: startX + CGFloat(file) * manager.squareDimension,
//                        y: boardSize - 16
//                    )
//                if manager.rotateBlackPieces {
//                    Text(files[file])
//                        .font(.caption)
//                        .foregroundColor(.white)
//                        .rotationEffect(.degrees(180))
//                        .position(
//                            x: startX + CGFloat(file) * manager.squareDimension,
//                            y: 8
//                        )
//                }
//            }
//
//            // Ranks (left)
//            ForEach(0..<8, id: \.self) { rank in
//                Text("\(rank + 1)")
//                    .font(.caption)
//                    .foregroundColor(.white)
//                    .position(
//                        x: 8,
//                        y: startY - (CGFloat(rank) * manager.squareDimension)
//                    )
//                if manager.rotateBlackPieces {                    
//                    Text("\(rank + 1)")
//                        .font(.caption)
//                        .foregroundColor(.white)
//                        .rotationEffect(.degrees(180))
//                        .position(
//                            x: boardSize - 16 ,
//                            y: startY - (CGFloat(rank) * manager.squareDimension)
//                        )
//                }
//            }
//        }
//        .allowsHitTesting(false)
//        .transition(.opacity)
//        .animation(.easeInOut(duration: 0.2), value: manager.showCoordinates)
//    }
//
//    private var squareSize: CGFloat {
//        boardSize / 8
//    }

struct BoardCoordinatesView: View {
    let squareSize: CGFloat

    var body: some View {
        ZStack {
            // Files (a–h)
            HStack(spacing: 0) {
                ForEach(0..<8) { file in
                    Text(String(UnicodeScalar(97 + file)!))
                        .foregroundStyle(.white.opacity(0.7))
                        .font(.caption.bold())
                        .frame(width: squareSize)
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 4)

            // Ranks (1–8)
            VStack(spacing: 0) {
                ForEach((0..<8).reversed(), id: \.self) { rank in
                    Text("\(rank + 1)")
                        .foregroundStyle(.white.opacity(0.7))
                        .font(.caption.bold())
                        .frame(height: squareSize)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 4)
        }
        .allowsHitTesting(false)
    }
}



