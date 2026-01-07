//
//  ChessView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 30.12.25.
//

import SwiftUI

struct ChessView: View {
    @EnvironmentObject var manager: GameManager

    var body: some View {
        VStack {
            ZStack(alignment: .center) {
                BoardView()
                PiecesLayer()
            }
            .onChange(of: manager.pendingPromotion) {
                guard let promotion = manager.pendingPromotion else { return }
                manager.promotePawn(at: promotion.square, to: .queen)
            }
            ControlsView()
        }
    }
}

#Preview {
    let previewEnvObject = GameManager()
    ChessView()
        .environmentObject(previewEnvObject)
}
