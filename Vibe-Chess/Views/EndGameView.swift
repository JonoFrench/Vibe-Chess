//
//  EndGameView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 3.01.26.
//

import SwiftUI

struct EndGameView: View {
    let result: GameResult
    let onRestart: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()

            VStack(spacing: 16) {
                Text(title)
                    .font(.largeTitle)
                    .foregroundColor(.white)

                Button("New Game") {
                    onRestart()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
            }
        }
    }

    private var title: String {
        switch result {
        case .checkmate(let winner):
            return "\(winner == .white ? "White" : "Black") wins by Checkmate"
        case .stalemate:
            return "Stalemate"
        }
    }
}
