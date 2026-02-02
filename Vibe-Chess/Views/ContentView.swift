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
                    colors: [Color.black,manager.accentColor.color.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .statusBar(hidden: true)
                
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
                            StartView()
                                .onAppear {
                                    manager.playAgainstAI = false
                                    manager.playFace2Face = true
                                    manager.resetGame()
                                }
                        } label: {
                            MenuButton(title: "Two Player Game", icon: "person.2.fill")
                        }
                        
                        NavigationLink {
                            StartViewAI()
                                .onAppear {
                                    manager.playAgainstAI = true
                                    manager.playFace2Face = false
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
                    .frame(maxWidth:.infinity)
                    .padding(.top, 20 * manager.deviceMulti)
                    
//                    Spacer()
                    // Me
                    VStack(spacing: 8 * manager.deviceMulti) {
                        Text("© Jonathan French 2026")
                            .font(.headline)
                            .foregroundStyle(.black)
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
    var isEnabled: Bool = true

    private var maxWidth: CGFloat? {
        manager.deviceType == .iPad ? 420 : nil
    }

    var body: some View {
        HStack(spacing: 16 * manager.deviceMulti) {
            Image(systemName: icon)
                .font(.title2)
                .opacity(isEnabled ? 1 : 0.5)

            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .opacity(isEnabled ? 1 : 0.5)

            Spacer()
        }
        .foregroundStyle(isEnabled ? .black : .gray)
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
        .frame(maxWidth: maxWidth)
        .background(
            RoundedRectangle(cornerRadius: 18 * manager.deviceMulti)
                .fill(Color.white.opacity(isEnabled ? 1 : 0.9))
        )
        .shadow(
            color: .black.opacity(isEnabled ? 0.25 : 0),
            radius: 6 * manager.deviceMulti,
            y: 4 * manager.deviceMulti
        )
        .contentShape(Rectangle())
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}


#Preview {
    let previewEnvObject = GameManager()
    ContentView()
        .environmentObject(previewEnvObject)
}
