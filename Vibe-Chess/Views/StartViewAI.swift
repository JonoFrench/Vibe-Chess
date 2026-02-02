//
//  StartViewAI.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 20.01.26.
//

import SwiftUI

struct StartViewAI: View {
    @EnvironmentObject var manager: GameManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTimeControl: TimeControl = .ten
    @State private var selectedDifficulty: AIDifficulty = .medium
    @State private var showLoadSheet = false

    var body: some View {
        ZStack {
            LinearGradient(
//                colors: [Color.black, Color(.darkGray)],
                colors: [Color.black,manager.accentColor.color.opacity(0.8)],
              startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .statusBar(hidden: true)

            VStack(spacing: 32) {

                Text("Play vs Computer")
                    .font(.system(size: 38, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                Image(systemName: "cpu")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80 * manager.deviceMulti, height: 80 * manager.deviceMulti)
                    .foregroundStyle(.white.opacity(0.9))

                // ---- LOAD / RESUME ----
                VStack(spacing: 16) {
                    NavigationLink {
                            AIChessView()
                            .onAppear {
                                manager.loadGame(SaveManager.loadAutoResume(playAgainstAI: true)!)
                            }
                    } label: {
                        MenuButton(
                            title: "Resume Current Game",
                            icon: "play.circle.fill",
                            isEnabled: SaveManager.loadAutoResume(playAgainstAI: true) != nil
                        )
                    }.disabled(
                        SaveManager.loadAutoResume(playAgainstAI: true) == nil
                    )
                    
                    Button {
                        showLoadSheet = true
                    } label: {
                        MenuButton(
                            title: "Load Saved Game",
                            icon: "tray.and.arrow.down.fill"
                        )
                    }.disabled(
                        SaveManager.loadAutoResume(playAgainstAI: true) == nil
                    )
                }

                Spacer()

                // ---- AI DIFFICULTY ----
                VStack(spacing: 16) {
                    Text("Select Difficulty")
                        .font(.headline)
                        .foregroundStyle(.gray)

                    Picker("Difficulty", selection: $selectedDifficulty) {
                        ForEach(AIDifficulty.allCases) { level in
                            Text(level.displayName).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                }

                // ---- TIME CONTROL ----
                VStack(spacing: 16) {
                    Text("Select Game Time")
                        .font(.headline)
                        .foregroundStyle(.gray)

                    Picker("Time Control", selection: $selectedTimeControl) {
                        ForEach(TimeControl.allCases) { tc in
                            Text(tc.rawValue).tag(tc)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                }

                // ---- START GAME ----
                NavigationLink {
                    AIChessView()
                        .onAppear {
                            manager.playAgainstAI = true
                            manager.playFace2Face = false
                            manager.aiDifficulty = selectedDifficulty

                            manager.resetGame()

                            // Wire the clock
                            if let seconds = selectedTimeControl.seconds {
                                manager.clock.whiteTime = seconds
                                manager.clock.blackTime = seconds
                            }
                        }
                } label: {
                    MenuButton(
                        title: "Start New Game",
                        icon: "cpu"
                    )
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
        }
        .sheet(isPresented: $showLoadSheet) {
            SavedGamesListView(filter: .ai)
                .environmentObject(manager)
        }
        .onChange(of: manager.shouldReturnToMainMenu) {
            if manager.shouldReturnToMainMenu {
                dismiss()
            }
        }
        .navigationDestination(isPresented: $manager.shouldOpenBoard) {
            AIChessView()
        }
    }
}
