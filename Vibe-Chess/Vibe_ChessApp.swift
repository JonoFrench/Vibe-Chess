//
//  Vibe_ChessApp.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 30.12.25.
//

import SwiftUI

@main
struct Vibe_ChessApp: App {
    @StateObject private var manager = GameManager()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(manager)
        }
    }
}
