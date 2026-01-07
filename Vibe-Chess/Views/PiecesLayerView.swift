//
//  PiecesLayerView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 1.01.26.
//

import SwiftUI

struct PiecesLayer: View {
    @EnvironmentObject var manager: GameManager
    @Namespace private var pieceNamespace

    var body: some View {
        let boardSize = manager.squareDimension * 8

        ZStack {
            ForEach(0..<64, id: \.self) { index in
                let square = Square(
                    file: index % 8,
                    rank: index / 8
                )

                if let piece = manager.board[square] {
                    SquareView(
                        piece: piece,
                        size: manager.squareDimension,
                        square: square,
                        namespace: pieceNamespace
                    )
                    
//                    .matchedGeometryEffect(
//                        id: "\(piece.color)-\(piece.type)-\(square.file)-\(square.rank)",
//                        in: pieceNamespace,
//                        properties: .position
//                    )
//                    .animation(.easeInOut(duration: 1.25), value: manager.board)
                    .position(
                        square.center(
                            squareSize: manager.squareDimension,
                            boardSize: boardSize
                        )
                    )
                }
            }
        }
        .frame(width: boardSize, height: boardSize)
    }
}
