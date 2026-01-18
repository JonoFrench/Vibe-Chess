//
//  ContentView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 30.12.25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var manager: GameManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.black, Color(.darkGray)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40 * manager.deviceMulti) {
                    
                    // Title
                    VStack(spacing: 8 * manager.deviceMulti) {
                        Text("VIBE CHESS")
                            .font(.system(size: 42 * manager.deviceMulti, weight: .bold, design: .serif))
                            .foregroundStyle(.white)
                        
                        Text("Play. Think. Win.")
                            .font(.headline)
                            .foregroundStyle(.gray)
                    }
                    
                    // Chess icon / hero
                    Image(systemName: "checkerboard.rectangle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120 * manager.deviceMulti, height: 120 * manager.deviceMulti)
                        .foregroundStyle(.white.opacity(0.9))
                    
                    // Menu buttons
                    VStack(spacing: 20 * manager.deviceMulti) {
                        
                        NavigationLink {
                            HumanGameSetupView()
                            //ChessView()
                                .onAppear {
                                    manager.playAgainstAI = false
                                    manager.rotateBlackPieces = true
                                    manager.resetGame()
                                }
                        } label: {
                            MenuButton(title: "Human vs Human", icon: "person.2.fill")
                        }
                        
                        NavigationLink {
                            ChessView()
                                .onAppear {
                                    manager.playAgainstAI = true
                                    manager.rotateBlackPieces = false
                                    manager.resetGame()
                                }
                        } label: {
                            MenuButton(title: "Play vs Computer", icon: "cpu")
                        }
                        
                        NavigationLink {
                            DemoView()
                                .onAppear {
                                }
                        } label: {
                            MenuButton(title: "Demo & Learn", icon: "graduationcap")
                        }
                        
                        NavigationLink {
                            InstructionsView()
                                .onAppear {
                                }
                        } label: {
                            MenuButton(title: "Instructions", icon: "info.circle")
                        }
                        //                        Button {
                        //                            let didLoad = manager.resumeLastGame()
                        //                            if !didLoad {
                        //                                // Optional: show an alert "No saved game"
                        //                            }
                        //                        } label: {
                        //                            MenuButton(title: "Resume Last Game", icon: "clock.arrow.circlepath")
                        //                        }
                        //                        .disabled(SaveManager.loadMostRecentGame() == nil)
                        //
                        
//                        NavigationLink(
//                            destination: ChessView(),
//                            isActive: $manager.shouldOpenBoard) {
//                                EmptyView()
//                            }
                    }
                    .padding(.top, 20 * manager.deviceMulti)
                    
                    Spacer()
                    // Me
                    VStack(spacing: 8 * manager.deviceMulti) {
                        Text("© Jonathan French 2026")
                            .font(.headline)
                            .foregroundStyle(.gray)
                    }
                }
                .padding(.top, 80 * manager.deviceMulti )
                .padding(.horizontal, 24 * manager.deviceMulti)
            }.onAppear {
                manager.shouldReturnToMainMenu = false
            }
        }
    }
}

struct MenuButton: View {
    @EnvironmentObject var manager: GameManager
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16 * manager.deviceMulti) {
            Image(systemName: icon)
                .font(.title2)
            
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            
            Spacer()
        }
        .foregroundStyle(.black)
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16 * manager.deviceMulti)
                .fill(Color.white)
        )
        .shadow(color: .black.opacity(0.25), radius: 6 * manager.deviceMulti, y: 4 * manager.deviceMulti)
    }
}

#Preview {
    let previewEnvObject = GameManager()
    ContentView()
        .environmentObject(previewEnvObject)
}
