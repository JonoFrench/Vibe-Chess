//
//  StartView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 15.01.26.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject var manager: GameManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTimeControl: TimeControl = .ten
    @State private var showLoadSheet = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black,manager.accentColor.color.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .statusBar(hidden: true)

            VStack(spacing: 32) {
                
                Text("Two Player Game")
                    .font(.system(size: 38, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                Image(systemName: "person.2.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80 * manager.deviceMulti, height: 80 * manager.deviceMulti)
                    .foregroundStyle(.white.opacity(0.9))
                
                VStack(spacing: 16) {
                    NavigationLink {
                        ChessView()
                            .onAppear {
                                manager.loadGame(SaveManager.loadAutoResume(playAgainstAI: false)!)
                            }
                    } label: {
                        MenuButton(title: "Resume Current Game",
                                   icon: "play.circle.fill",
                                   isEnabled: SaveManager.loadAutoResume(playAgainstAI: false) != nil)
                    }
                    .disabled(
                        SaveManager.loadAutoResume(playAgainstAI: false) == nil
                    )
                    
                    Button {
                        showLoadSheet = true
                    }
                    label: {
                        MenuButton(title: "Load Saved Game",
                                   icon: "tray.and.arrow.down.fill",
                                   isEnabled: SaveManager.loadUserGames(filter: false).count > 0)
                    }.disabled(
                        SaveManager.loadUserGames(filter: false).count == 0
                    )
                }
                Spacer()
                VStack(spacing: 16 * manager.deviceMulti) {
                    Toggle(
                        "Play Face to Face",
                        isOn: $manager.playFace2Face
                    ).foregroundStyle(.white)
                    
                    VStack(spacing: 16) {
                        Text("Select Game Time")
                            .font(.headline)
                            .foregroundStyle(.white)
                        
                        Picker("Time Control", selection: $selectedTimeControl) {
                            ForEach(TimeControl.allCases) { tc in
                                Text(tc.rawValue).tag(tc)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                    }
                }.frame(width:420)
                NavigationLink {
                    ChessView()
                        .onAppear {
//                            manager.playAgainstAI = false
//                            manager.playFace2Face = true
//                            manager.resetGame()
                            
                            // Wire the clock
                            if let seconds = selectedTimeControl.seconds {
                                manager.clock.whiteTime = seconds
                                manager.clock.blackTime = seconds
                            }
                        }
                } label: {
                    MenuButton(title: "Start New Game", icon: "person.2.fill")
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
        }
        .sheet(isPresented: $showLoadSheet) {
            SavedGamesListView(filter: .human)
                .environmentObject(manager)
        }
        .onChange(of: manager.shouldReturnToMainMenu) {
            if manager.shouldReturnToMainMenu {
                dismiss()
            }
        }
        .navigationDestination(isPresented: $manager.shouldOpenBoard) {
            ChessView()
//                .onAppear {
//                    //                            manager.playAgainstAI = false
//                    //                            manager.playFace2Face = true
//                    //                            manager.resetGame()
//                    
//                    // Wire the clock
//                    if let seconds = selectedTimeControl.seconds {
//                        manager.clock.whiteTime = seconds
//                        manager.clock.blackTime = seconds
//                    }
//                }
        }
    }
}
