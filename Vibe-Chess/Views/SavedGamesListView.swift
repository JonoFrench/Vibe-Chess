//
//  SavedGamesListView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 15.01.26.
//

import SwiftUI

import SwiftUI

struct SavedGamesListView: View {
    let filter: SavedGameFilter
    @EnvironmentObject var manager: GameManager
    @Environment(\.dismiss) var dismiss

    @State private var games: [SavedGame] = []
    var body: some View {
        NavigationStack {
            List {
                ForEach(games) { game in
                    Button {
                        manager.loadGame(game)
                        dismiss()
                    } label: {
                        VStack(alignment: .leading) {
                            Text(game.name)
                                .font(.headline)

                            Text(game.date.formatted())
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete { indexSet in
                    games.remove(atOffsets: indexSet)
                    SaveManager.saveGames(games)
                }
            }
            .navigationTitle("Saved Games")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
        .onAppear {
            games = SaveManager.loadUserGames(filter: manager.playAgainstAI)
        }
    }
}
