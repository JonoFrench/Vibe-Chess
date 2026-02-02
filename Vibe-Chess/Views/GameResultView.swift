//
//  GameResultView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 22.01.26.
//

import SwiftUI

struct GameResultView: View {
    @EnvironmentObject var manager: GameManager
    @Environment(\.dismiss) private var dismiss
    var result:GameResult
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black,manager.accentColor.color.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .statusBar(hidden: true)

            VStack(spacing: 24) {

                Text(resultTitle)
                    .font(.system(size: 42, weight: .bold, design: .serif))
                    .foregroundStyle(.white)

                Text(manager.gameResult?.titleText ?? "")
                    .font(.headline)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)

                // Chess icon / hero
                Image(systemName: "checkerboard.rectangle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120 * manager.deviceMulti, height: 120 * manager.deviceMulti)
                    .foregroundStyle(.white.opacity(0.9))
                Spacer()

                VStack(spacing: 16) {

//                    Button {
////                        manager.enterReviewMode()
//                    } label: {
//                        MenuButton(title: "Review Game", icon: "list.bullet.rectangle")
//                    }

                    Button {
                        manager.resetGame()
                        dismiss()
                    } label: {
                        MenuButton(title: "New Game", icon: "plus.circle")
                    }

                    Button(role: .destructive) {
//                        manager.returnToMainMenu()
                        manager.resetGame()
                        manager.shouldReturnToMainMenu = true
                        //dismiss()
                    } label: {
                        MenuButton(title: "Main Menu", icon: "house")
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 80)
        }
    }

    private var resultTitle: String {
        guard let result = manager.gameResult else { return "" }
        if let winner = result.winner {
            return "\(winner.displayName) Wins"
        } else {
            return "Draw"
        }
    }
}



struct ResultBadge: View {
    let result: GameResult?

    var body: some View {
        Text(result?.shortResult ?? "")
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .clipShape(Capsule())
            .foregroundStyle(.white)
    }

    private var color: Color {
        guard let result else { return .gray }
        return result.isDraw ? .gray : .green
    }
}
