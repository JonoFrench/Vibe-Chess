//
//  ControlsView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 6.01.26.
//

import SwiftUI

struct ControlsView: View {
    @EnvironmentObject var manager: GameManager

    var body: some View {
        HStack {
            // Undo
            Button {
                manager.undoTurn()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                Image(systemName: "arrow.uturn.backward")
                    .font(.title2).foregroundColor(.white)
            }
            .disabled(!manager.canUndo)
            

            Spacer()

            // Placeholder for future controls
            // e.g. Redo, Analysis, Clock
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}



#Preview {
    ControlsView()
}
