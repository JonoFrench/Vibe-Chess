//
//  AIChessView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 25.01.26.
//

import SwiftUI

struct AIChessView: View {
    @EnvironmentObject var manager: GameManager
    @Environment(\.dismiss) private var dismiss
    @State private var showGameOptions = false
    @State private var showQuitConfirmation = false
    
    var body: some View {
        let boardSize = manager.squareDimension * 8
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [Color.black,manager.accentColor.color.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .statusBar(hidden: true)

                VStack(spacing: 16) {
                    
                    // Top spacer (room for status / clocks later)
                    //                    Spacer().frame(height: 24)
                    Spacer()
                    
                    ZStack {
                        // Chess board
                        BoardView()
                        PiecesLayer()
                    }
                    .padding(manager.deviceType == .iPad ? 30 : 20)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay{
                        if manager.showCoordinates {
                            BoardCoordinatesView(
                                squareSize: manager.squareDimension
                            )
                            .transition(.opacity)
                        }
                    }
                    .frame(width:boardSize,height: boardSize)
                    .animation(.easeInOut(duration: 0.2), value: manager.showCoordinates)
                    .rotationEffect(
                        manager.rotateBoardForBlack ? .degrees(180) : .degrees(0)
                    )
                    .animation(.easeInOut(duration: 0.25), value: manager.rotateBoardForBlack)
                    Spacer()
                    // Controls (undo, resign, etc.)
//                    if !manager.rotateBlackPieces {
                        ControlsView(isTopPerspective: false, controlColor: .white)
                            .padding(.horizontal)
                            .padding(.top, 8)
//                    } else {
//                        HStack {
//                            ControlsView(isTopPerspective: false, controlColor: .white)
////                                Spacer()
//                            ControlsView(isTopPerspective: false, controlColor: .black)
//                        }.padding(.horizontal)
//                            .padding(.top, 8)
//                    }
                    // Move list
                    //                    if manager.playAgainstAI {
//                    MoveListView()
//                        .padding(.horizontal)
//                        .padding(.top, 4)
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
                .sheet(item: $manager.gameResult) { result in
                    let _ = print("GameResultView \(result)")
                        GameResultView(result: result)
                }

            }
            
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: manager.shouldReturnToMainMenu) {
            if manager.shouldReturnToMainMenu {
                dismiss()
            }
        }
    }
}
#Preview {
    AIChessView()
}
