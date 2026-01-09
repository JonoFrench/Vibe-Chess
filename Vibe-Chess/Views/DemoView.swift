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
    let loadPosition: (GameManager) -> Void
}

extension DemoItem {

    static let enPassant = DemoItem(
        title: "En Passant",
        description: "A special pawn capture that must be played immediately after a two-square pawn advance.",
        loadPosition: { $0.loadEnPassantTestPosition() }
    )

    static let promotion = DemoItem(
        title: "Pawn Promotion",
        description: "Pawns promote when they reach the last rank.",
        loadPosition: { $0.loadPromotionTestPosition() }
    )

    static let castling = DemoItem(
        title: "Castling",
        description: "King-side and queen-side castling rules.",
        loadPosition: { $0.loadCastlingTest() }
    )

    static let checkmate = DemoItem(
        title: "Check & Checkmate",
        description: "Delivering and recognizing checkmate.",
        loadPosition: { $0.loadCheckmateTestPosition() }
    )
}


struct DemoView: View {
    @EnvironmentObject var manager: GameManager

    let demos: [DemoItem] = [
        .promotion,
        .castling,
        .enPassant,
        .checkmate
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black, .gray.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

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
        }
    }
}

struct DemoCardView: View {
    let demo: DemoItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(demo.title)
                .font(.headline)
                .foregroundStyle(.white)

            Text(demo.description)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}


