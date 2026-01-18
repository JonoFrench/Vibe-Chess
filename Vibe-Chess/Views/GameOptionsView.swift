//
//  GameOptionsView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 9.01.26.
//

import SwiftUI

struct GameOptionsView: View {
    @EnvironmentObject var manager: GameManager
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    @State private var showResignConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                
                Section("Display") {
                    Picker("Time Control", selection: $manager.timeControl) {
                        ForEach(TimeControl.allCases) { control in
                            Text(control.rawValue).tag(control)
                        }
                    }
                    
                    Toggle(
                        "Show Coordinates",
                        isOn: $manager.showCoordinates
                    )
                    Toggle(
                        "Rotate Black Pieces",
                        isOn: $manager.rotateBlackPieces
                    )
                    Toggle(
                        "Show Last Move",
                        isOn: $manager.showLastMove
                    )
                    
                }
                
                Section("Game") {
                    Button("Save Game") {
                        manager.saveCurrentGame(named: "Game on \(Date())")
                        manager.stopClock()
                        manager.shouldReturnToMainMenu = true
                        isPresented = false
                    }
                    
                    Button("Resign Game", role: .destructive) {
                        showResignConfirmation = true
                    }
                }
            }
            .navigationTitle("Game Options")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
            .alert(
                "Are you sure you want to resign?",
                isPresented: $showResignConfirmation
            ) {
                Button("Resign", role: .destructive) {
                    //manager.resetGame()
                    manager.stopClock()
                    manager.shouldReturnToMainMenu = true
                    isPresented = false
                }
                Button("Cancel", role: .cancel) {
                    isPresented = false
                }
            }
        }
//    }
}
