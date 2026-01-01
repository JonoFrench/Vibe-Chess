//
//  ChessView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 30.12.25.
//

import SwiftUI

struct ChessView: View {
    var body: some View {
        ZStack(alignment: .center) {
            BoardView()
            PiecesLayer()
        }
    }
}

#Preview {
    let previewEnvObject = GameManager()
    ChessView()
        .environmentObject(previewEnvObject)
}
