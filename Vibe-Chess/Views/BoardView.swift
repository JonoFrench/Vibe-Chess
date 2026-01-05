//
//  BoardView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 30.12.25.
//

import SwiftUI

struct BoardView: View {
    @EnvironmentObject var manager: GameManager

    var body: some View {
        VStack(spacing: 0) {
            ForEach((0..<8).reversed(), id: \.self) { rank in
                HStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { file in
                        let square = Square(file: file, rank: rank)
  //                      let piece = manager.board[square]
                        
                        ZStack {
                            Rectangle()
                                .fill((file + rank).isMultiple(of: 2)
                                      ? Color(.boardWhite)
                                      : Color(.boardBlack))
                            if manager.selectedSquare == square {
                                Rectangle()
                                    .stroke(Color(.selected), lineWidth: 2)
                            }
                            
                            if square == manager.lastMove?.from ||
                               square == manager.lastMove?.to {
                                Color.yellow.opacity(0.3)
                            }

                            if let selected = manager.selectedSquare {
                                let legalTargets = manager
                                    .legalMoves(from: selected)
                                    .map(\.to)
                                
                                if legalTargets.contains(square) {
                                    if manager.board[square] != nil {
                                        Circle()
                                            .stroke(Color.red, lineWidth: 4)
                                            .padding(6)
                                    } else {
                                        Circle()
                                            .fill(Color(.selected).opacity(0.35))
                                            .padding(manager.squareDimension * 0.35)
                                    }
                                }
                            }
                        }.frame(width: manager.squareDimension, height: manager.squareDimension)
                            .onTapGesture {
                                manager.select(square)
                            }
                    }
                }
            }
        }
        .overlay {
            if let result = manager.gameResult {
                EndGameView(result: result) {
                    manager.resetGame()
                }
            }
        }
    }
    
    
    
}

#Preview {
    let previewEnvObject = GameManager()
    return BoardView()
        .environmentObject(previewEnvObject)
}
