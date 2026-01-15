//
//  PauseView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 14.01.26.
//

import SwiftUI

struct PauseView: View {
    @EnvironmentObject var manager: GameManager
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text("Paused")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Button("Resume") {
                    manager.paused = false
                    manager.clock.isRunning = true
                }
                .padding()
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Text("Paused")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(180))
                
            }
        }
    }
}

#Preview {
    PauseView()
}
