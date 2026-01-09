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
                
                VStack(spacing: 40) {
                    
                    // Title
                    VStack(spacing: 8) {
                        Text("VIBE CHESS")
                            .font(.system(size: 42, weight: .bold, design: .serif))
                            .foregroundStyle(.white)
                        
                        Text("Play. Think. Win.")
                            .font(.headline)
                            .foregroundStyle(.gray)
                    }
                    
                    // Chess icon / hero
                    Image(systemName: "checkerboard.rectangle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundStyle(.white.opacity(0.9))
                    
                    // Menu buttons
                    VStack(spacing: 20) {
                        
                        NavigationLink {
                            ChessView()
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
                        
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    // Me
                    VStack(spacing: 8) {
                        Text("(c) Jonathan French 2026")
                            .font(.headline)
                            .foregroundStyle(.gray)
                    }
                    
                }
                .padding(.top, 80)
                .padding(.horizontal, 24)
            }
        }
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
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
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        .shadow(color: .black.opacity(0.25), radius: 6, y: 4)
    }
}

#Preview {
    let previewEnvObject = GameManager()
    ContentView()
        .environmentObject(previewEnvObject)
}
