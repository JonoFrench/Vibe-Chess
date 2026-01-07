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
            Button("Undo") {
                manager.undoTurn()
            }
        }
    }
}


#Preview {
    ControlsView()
}
