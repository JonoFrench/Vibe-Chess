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
                    .position(
                        square.center(
                            squareSize: manager.squareDimension,
                            boardSize: boardSize
                        )
                    )
                }
            }
        }.onChange(of: manager.pendingPromotion) {
            guard let promotion = manager.pendingPromotion else { return }
            manager.promotePawn(at: promotion.square, to: .queen)
        }
        .frame(width: boardSize, height: boardSize)
        .overlay {
            if let result = manager.gameResult {
                EndGameView(result: result) {
                    manager.resetGame()
                }
            }
        }
    }
}
