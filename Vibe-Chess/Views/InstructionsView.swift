//
//  InstructionsView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 8.01.26.
//

import SwiftUI

import SwiftUI

struct InstructionsView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black, .gray.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: Title
                    Text("How to Play Chess")
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .padding(.bottom, 8)

                    divider

                    // MARK: The Board
                    sectionHeader("The Board")

                    bodyText("""
                    Chess is played on an 8×8 board with alternating light and dark squares.

                    • Files (columns) are labeled a–h  
                    • Ranks (rows) are labeled 1–8  

                    Every square has a unique coordinate such as e4, d5, or a1.

                    White starts at the bottom (ranks 1–2).  
                    Black starts at the top (ranks 7–8).
                    """)

                    divider

                    // MARK: Pieces
                    sectionHeader("The Pieces")

                    bodyText("""
                    Each player begins with:
                    • 1 King
                    • 1 Queen
                    • 2 Rooks
                    • 2 Knights
                    • 2 Bishops
                    • 8 Pawns
                    """)

                    divider

                    // MARK: King
                    pieceHeader("♔ King")

                    bodyText("""
                    • Moves one square in any direction.  
                    • You may not move into check.  
                    • If your king is trapped in check, it's checkmate.
                    """)

                    boldText("Special move: Castling")
                    bodyText("""
                    The king moves two squares toward a rook, which jumps over the king.

                    Allowed only if:
                    • Neither piece has moved
                    • No pieces are between them
                    • The king is not in check
                    • The king does not pass through check
                    """)

                    divider

                    // MARK: Queen
                    pieceHeader("♕ Queen")

                    bodyText("""
                    The most powerful piece.
                    Moves any number of squares horizontally, vertically, or diagonally.
                    """)

                    divider

                    // MARK: Rook
                    pieceHeader("♖ Rook")

                    bodyText("""
                    Moves any number of squares horizontally or vertically.
                    Also participates in castling.
                    """)

                    divider

                    // MARK: Bishop
                    pieceHeader("♗ Bishop")

                    bodyText("""
                    Moves any number of squares diagonally.
                    Each bishop always stays on its original color square.
                    """)

                    divider

                    // MARK: Knight
                    pieceHeader("♘ Knight")

                    bodyText("""
                    Moves in an “L” shape: two squares in one direction, then one perpendicular.

                    It is the only piece that can jump over other pieces.
                    """)

                    divider

                    // MARK: Pawn
                    pieceHeader("♙ Pawn")

                    bodyText("""
                    • Moves one square forward  
                    • Captures one square diagonally  
                    • On its first move, may move two squares
                    """)

                    boldText("En Passant")
                    bodyText("""
                    If a pawn moves two squares past your pawn, you may capture it as if it moved only one square.
                    """)

                    boldText("Promotion")
                    bodyText("""
                    When a pawn reaches the far rank, it becomes a Queen, Rook, Bishop, or Knight.
                    Most players choose a Queen.
                    """)

                    divider

                    // MARK: Game Endings
                    sectionHeader("How a Game Ends")

                    bodyText("""
                    A game can end in five ways:

                    1. Checkmate – the king cannot escape.
                    2. Resignation – a player gives up.
                    3. Stalemate – no legal moves, but not in check (draw).
                    4. Threefold repetition – same position occurs three times (draw).
                    5. 50-move rule – 50 moves without a pawn move or capture (draw).
                    """)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
            }
        }
        .navigationTitle("Instructions")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Small styling helpers

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.3))
            .frame(height: 1)
            .padding(.vertical, 8)
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.title2.bold())
            .foregroundColor(.white)
    }

    private func pieceHeader(_ text: String) -> some View {
        Text(text)
            .font(.title3.bold())
            .foregroundColor(.white)
    }

    private func bodyText(_ text: String) -> some View {
        Text(text)
            .font(.body)
            .foregroundColor(.white.opacity(0.85))
            .lineSpacing(4)
    }

    private func boldText(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundColor(.white)
            .padding(.top, 6)
    }
}

#Preview {
    InstructionsView()
}
