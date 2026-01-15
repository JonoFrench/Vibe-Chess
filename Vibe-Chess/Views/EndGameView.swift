//
//  EndGameView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 3.01.26.
//

import SwiftUI

struct EndGameView: View {
    @Environment(\.dismiss) private var dismiss

    let result: GameResult
    let onRestart: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()

            VStack(spacing: 16) {
                Text(title)
                    .font(.largeTitle)
                    .foregroundColor(.white)

                Button("Finish") {
                    dismiss()
                    //onRestart()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                
                Text(title)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(180))

            }
        }
    }

    private var title: String {
        switch result {
        case .checkmate(let winner):
            return "\(winner == .white ? "White" : "Black") wins by Checkmate"
        case .stalemate:
            return "Stalemate"
        case .drawByFiftyMoveRule:
            return "Draw by 50 move rule"
        case .drawByThreefoldRepetition:
            return "Draw by Threefold Repetition"
        case .timeout(let winner):
            return "\(winner == .white ? "White" : "Black") wins by Time"
        case .resignation(let winner):
            return "\(winner == .white ? "White" : "Black") wins by Resignation"

        }
    }
}
