//
//  StartView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 15.01.26.
//

import SwiftUI

import SwiftUI

struct HumanGameSetupView: View {
    @EnvironmentObject var manager: GameManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTimeControl: TimeControl = .ten
    @State private var showLoadSheet = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(.darkGray)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                
                Text("Human vs Human")
                    .font(.system(size: 38, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                
                VStack(spacing: 16) {
                    Button {
                        showLoadSheet = true
                    }
                    label: {
                        MenuButton(title: "Load Saved Game", icon: "clock.arrow.circlepath")
                    }                }
                
                //                Spacer()
                
                NavigationLink {
                    if manager.resumeLastGame() {
                        ChessView()
                    }
                } label: {
                    MenuButton(title: "Resume Last Game", icon: "clock.arrow.circlepath")
                }
                //.disabled(SaveManager.loadMostRecentGame() == nil)
                
                
                Spacer()
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
                
                NavigationLink {
                    ChessView()
                        .onAppear {
                            manager.playAgainstAI = false
                            manager.rotateBlackPieces = true
                            manager.resetGame()
                            
                            // Wire the clock
                            manager.clock.whiteTime = selectedTimeControl.seconds
                            manager.clock.blackTime = selectedTimeControl.seconds
                        }
                } label: {
                    MenuButton(title: "Start New Game", icon: "info.circle")
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
        }
        .sheet(isPresented: $showLoadSheet) {
            SavedGamesListView()
                .environmentObject(manager)
        }
        .onChange(of: manager.shouldReturnToMainMenu) {
            if manager.shouldReturnToMainMenu {
                dismiss()
            }
        }
        .navigationDestination(isPresented: $manager.shouldOpenBoard) {
            ChessView()
        }

    }
}
