//
//  SaveManager.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 15.01.26.
//

import Foundation

//struct SaveManager {

enum SaveManager {
    private static let key = "saved_games"
    //    }
    
    
    static func loadSavedGames() -> [SavedGame] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let games = try? JSONDecoder().decode([SavedGame].self, from: data)
        else {
            return []
        }
        return games
    }
    
    static func saveGames(_ games: [SavedGame]) {
        guard let data = try? JSONEncoder().encode(games) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
    
    static func saveAutoResume(_ game: SavedGame) {
        var games = loadSavedGames()
        games.removeAll { $0.isAutoSave && $0.playAgainstAI == game.playAgainstAI }
        games.append(game)
        saveGames(games)
    }
    
    static func loadAutoResume(playAgainstAI: Bool) -> SavedGame? {
        loadSavedGames().first {
            $0.isAutoSave &&
            $0.playAgainstAI == playAgainstAI &&
            $0.status == .inProgress
        }
    }
    static func deleteAutoResume(playAgainstAI: Bool) {
        var games = loadSavedGames()
        games.removeAll { $0.isAutoSave && $0.playAgainstAI == playAgainstAI }
        saveGames(games)
    }
    
    static func loadUserGames(filter: Bool) -> [SavedGame] {
        loadSavedGames()
            .filter { !$0.isAutoSave && $0.playAgainstAI == filter }
            .sorted { $0.date > $1.date }
    }    
}

enum SavedGameFilter {
    case all
    case human
    case ai
}

extension SaveManager {
    
    static func loadSavedGames(
        filteredBy filter: SavedGameFilter
    ) -> [SavedGame] {
        
        let games = loadSavedGames()
        
        switch filter {
        case .all:
            return games
            
        case .human:
            return games.filter { !$0.playAgainstAI }
            
        case .ai:
            return games.filter { $0.playAgainstAI }
        }
    }
    
    static func loadMostRecentGame(
        filteredBy filter: SavedGameFilter
    ) -> SavedGame? {
        
        loadSavedGames(filteredBy: filter)
            .sorted { $0.date > $1.date }
            .first
    }
}


