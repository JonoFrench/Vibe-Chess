//
//  DemoView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 8.01.26.
//

import SwiftUI

struct DemoItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let instructions: String
    let loadPosition: (GameManager) -> Void
}

extension DemoItem {

    static let selectedMove = DemoItem(
        title: "Selected Move",
        description: "Selecting a piece on the board.",
        instructions: "Selecting a piece on the board will hilight it in purple, possible moves are shown with purple dots, opponent pieces for taking are hilighted in red.",
        loadPosition: { $0.loadEnPassantTestPosition() }
    )

    static let possibleMove = DemoItem(
        title: "UnComitted Move",
        description: "Playing against a human opponent.",
        instructions: "Playing against a human opponent, selected moves are shown with start square hilighted in blue and end square in green. The player needs to press play to commit the move or undo to reset the board.",
        loadPosition: { $0.loadEnPassantTestPosition() }
    )

    static let currentMove = DemoItem(
        title: "Last Move",
        description: "The last move.",
        instructions: "The last move, white or black, is show on the board with the start and end squares hilighted in gold.",
        loadPosition: { $0.loadEnPassantTestPosition() }
    )

    static let enPassant = DemoItem(
        title: "En Passant",
        description: "A special pawn capture that must be played immediately after a two-square pawn advance.",
        instructions: "We can see the selected white pawn here at e5 has 2 possible positions to move to. Selecting position d6 takes the black pawn at d5 in the en-passant move.",
        loadPosition: { $0.loadEnPassantTestPosition() }
    )

    static let promotion = DemoItem(
        title: "Pawn Promotion",
        description: "Pawns promote when they reach the last rank.",
        instructions: "Here we can see the white pawn at e7 selected. Moving forward to e8 promotes the pawn to a queen.",
        loadPosition: { $0.loadPromotionTestPosition() }
    )

    static let castling = DemoItem(
        title: "Castling",
        description: "King-side and queen-side castling rules.",
        instructions: "The King selected here at e1 can move two positions to the left (queen side) or right (king side) and it then swaps position with the castle.",
        loadPosition: { $0.loadCastlingTest() }
    )

    static let checkmate = DemoItem(
        title: "Check & Checkmate",
        description: "Delivering and recognizing checkmate.",
        instructions: "The white Queen here at g6 has many squares to move to, moving simply forward to g7 put the black King into Checkmate and wins the game.",
        loadPosition: { $0.loadCheckmateTestPosition() }
    )
}


struct DemoView: View {
    @EnvironmentObject var manager: GameManager

    let demos: [DemoItem] = [
        .selectedMove,
        .currentMove,
        .possibleMove,
        .promotion,
        .castling,
        .enPassant,
        .checkmate
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black,manager.accentColor.color.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .statusBar(hidden: true)

            ScrollView {
                VStack(spacing: 20) {

                    VStack(spacing: 6) {
                        Text("Demo & Learn")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)

                        Text("Interactive chess rules & examples")
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.top, 40)

                    ForEach(demos) { demo in
                        NavigationLink {
                            DemoChessView(demo: demo)
                        } label: {
                            DemoCardView(demo: demo)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct DemoCardView: View {
    @EnvironmentObject var manager: GameManager
    let demo: DemoItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(demo.title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(demo.description)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .frame(
            maxWidth: manager.deviceType == .iPad ? 520 : .infinity,
            alignment: .leading
        )
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18 * manager.deviceMulti))
        .padding(.horizontal)
    }
}




