//
//  SaveManager.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 15.01.26.
//

import Foundation

struct SaveManager {

    static var savesURL: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("savedGames.json")
    }

    static func loadSavedGames() -> [SavedGame] {
        guard let data = try? Data(contentsOf: savesURL) else {
            return []
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return (try? decoder.decode([SavedGame].self, from: data)) ?? []
    }

    static func saveGames(_ games: [SavedGame]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601

        let data = try! encoder.encode(games)
        try! data.write(to: savesURL)
    }
    
    static func loadMostRecentGame() -> SavedGame? {
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("savedGames.json")

        guard let data = try? Data(contentsOf: url) else { return nil }

        let games = try? JSONDecoder().decode([SavedGame].self, from: data)
        return games?.last        // <-- most recent one
    }

}

