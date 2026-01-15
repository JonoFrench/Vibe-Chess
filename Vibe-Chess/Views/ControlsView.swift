//
//  ControlsView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 6.01.26.
//

import SwiftUI

struct ControlsView: View {
    @EnvironmentObject var manager: GameManager
    
    var isTopPerspective: Bool
    var controlColor:PieceColor
    //{
    //        manager.rotateBlackPieces
    //    }
    
    var body: some View {
        HStack {
            Spacer()
            undoButton
            Spacer()
            if !manager.playAgainstAI {
                if controlColor == .white { whiteClock } else { blackClock}
                Spacer()
                playButton
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(controlColor == manager.sideToMove ? .white : .clear, lineWidth: 4)
        )
        .padding(.horizontal)
        .rotationEffect(isTopPerspective ? .degrees(180) : .degrees(0))
    }
    
    private var undoButton: some View {
        Button("UnDo") {
            manager.undoTurn()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        //        label: {
        //            Image(systemName: "arrow.uturn.backward")
        //                .font(.title2)
        //                .foregroundColor(controlColor == manager.sideToMove ? .white : .gray)
        //        }
        .foregroundColor(controlColor == manager.sideToMove ? .white : .gray)
        .disabled(!manager.canUndo)
    }
    
    private var playButton: some View {
        Button("Play") {
            manager.commitStagedMove()
        }
        .foregroundColor(controlColor == manager.sideToMove ? .white : .gray)
        .disabled(manager.stagedMove == nil || controlColor != manager.sideToMove )
    }
    
    private var whiteClock: some View {
        ClockView(
            time: manager.clock.whiteTime,
            isActive: manager.sideToMove == .white
        )
        .onTapGesture {
            guard (manager.gameResult == nil) else { return }
            manager.paused = true
            manager.clock.isRunning = false
        }
    }
    
    private var blackClock: some View {
        ClockView(
            time: manager.clock.blackTime,
            isActive: manager.sideToMove == .black
        )
        .onTapGesture {
            guard (manager.gameResult == nil) else { return }
            manager.paused = true
            manager.clock.isRunning = false
        }

    }
}

#Preview {
    ControlsView(isTopPerspective: false,controlColor: .white)
}
