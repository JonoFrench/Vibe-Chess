//
//  ChessView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 30.12.25.
//

import SwiftUI

struct ChessView: View {
    @EnvironmentObject var manager: GameManager
    @Environment(\.dismiss) private var dismiss
    @State private var showGameOptions = false
    @State private var showQuitConfirmation = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background (same style as ContentView)
                LinearGradient(
                    colors: [Color.black, Color(.darkGray)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    
                    // Top spacer (room for status / clocks later)
                    Spacer().frame(height: 24)
                    
                    ZStack {
                    // Chess board
                    ZStack {
                        BoardView()
                        PiecesLayer()
                        // Coordinates
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    //.padding(.horizontal)
                    if manager.showCoordinates {
                        BoardCoordinatesLayer(
                            boardSize: manager.squareDimension * 8,
                            padding: 20
                        )
                    }
                }
                Spacer()
                    // Controls (undo, resign, etc.)
                    ControlsView()
                        .padding(.top, 8)

                    // Move list
                    MoveListView()
                        .padding(.horizontal)
                        .padding(.top, 4)

                    Spacer(minLength: 12)
                }
                .onAppear {
                    manager.squareDimension = geo.size.width * 0.90 / 8
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showGameOptions = true
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.title3)
                        }
                    }
                }
                .sheet(isPresented: $showGameOptions) {
                    GameOptionsView(isPresented: $showGameOptions)
                        .environmentObject(manager)
                }
//
//                .confirmationDialog(
//                    "Game Options",
//                    isPresented: $showGameOptions,
//                    titleVisibility: .visible
//                ) {
//                    Toggle(
//                        "Rotate Black Pieces",
//                        isOn: $manager.rotateBlackPieces
//                    )
//                    
//                    Button("Save Game") {
//                        // TODO: save
//                    }
//
//                    Button("Resign Game", role: .destructive) {
//                        showQuitConfirmation = true
//                        // Navigation pop
//                    }
//
//                    Button("Cancel", role: .cancel) {}
//                }
                // 🔹 Quit confirmation
                .alert("Resign Game?", isPresented: $showQuitConfirmation) {
                    Button("Cancel", role: .cancel) {}

                    Button("Resign", role: .destructive) {
                        manager.resetGame()
                        dismiss()
                    }
                } message: {
                    Text("This game will be lost.")
                }
            }
            
        }
        .navigationBarBackButtonHidden(true)
    }
}


#Preview {
    let previewEnvObject = GameManager()
    ChessView()
        .environmentObject(previewEnvObject)
}
