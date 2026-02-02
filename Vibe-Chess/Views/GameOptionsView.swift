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
    @State private var showSaveSheet = false
    @State private var saveGameName = ""
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section("Display") {
                    Toggle(
                        "Show Coordinates",
                        isOn: $manager.showCoordinates
                    )
//                    Toggle(
//                        "Rotate Black Pieces",
//                        isOn: $manager.playFace2Face
//                    )
//                    Toggle(
//                        "Rotate Board for Black Move",
//                        isOn: $manager.rotateBoardForBlack
//                    )

                    Toggle(
                        "Show Last Move",
                        isOn: $manager.showLastMove
                    )
                    //
                    HStack {
                        ForEach(AppAccentColor.allCases) { accent in
                            Circle()
                                .fill(accent.color)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle()
                                        .stroke(.white, lineWidth: manager.accentColor == accent ? 3 : 0)
                                )
                                .onTapGesture {
                                    manager.accentColor = accent
                                }
                        }
                    }

                }
                Section("Gameplay") {
                    Picker("Time Control", selection: $manager.timeControl) {
                        ForEach(TimeControl.allCases) { control in
                            Text(control.rawValue).tag(control)
                        }
                    }
                    
                    Picker("AI Difficulty", selection: $manager.aiDifficulty) {
                        ForEach(AIDifficulty.allCases) { level in
                            Text(level.displayName).tag(level)
                        }
                    }
                }

                Section("Game") {
                    Button("Save Game") {
//                        manager.autoSave()
//                        manager.stopClock()
//                        manager.saveCurrentGame(named: "Game on \(Date())")
//                        manager.shouldReturnToMainMenu = true
//                        isPresented = false
                        saveGameName = defaultSaveName()
                        showSaveSheet = true
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
                    manager.endGame(.resignation(winner: manager.sideToMove))
                    manager.shouldReturnToMainMenu = true
                    isPresented = false
                }
                Button("Cancel", role: .cancel) {
                    isPresented = false
                }
            }
        
        .sheet(isPresented: $showSaveSheet) {
            NavigationStack {
                Form {
                    Section("Game Name") {
                        TextField("Enter game name", text: $saveGameName)
                            .textInputAutocapitalization(.words)
                    }
                }
                .navigationTitle("Save Game")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showSaveSheet = false
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            manager.autoSave()
                            manager.stopClock()
                            manager.saveCurrentGame(named: saveGameName.trimmingCharacters(in: .whitespaces))
                            manager.shouldReturnToMainMenu = true
                            showSaveSheet = false
                            isPresented = false
                        }
                        .disabled(saveGameName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
        }

    }
    private func defaultSaveName() -> String {
        if let currentSaveName = manager.currentSaveName {
            return currentSaveName
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return "Game – \(formatter.string(from: Date()))"
        }
    }

}
