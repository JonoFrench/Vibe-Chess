//
//  DemoChessView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 8.01.26.
//

import SwiftUI

struct DemoChessView: View {
    @EnvironmentObject var manager: GameManager
    let demo: DemoItem
    
    var body: some View {
        let boardSize = manager.squareDimension * 8
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [Color.black,manager.accentColor.color.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .statusBar(hidden: true)

                VStack(spacing: 16) {
                    
                    // Title + description
                    VStack(spacing: 6) {
                        Text(demo.title)
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                        
                        Text(demo.description)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.75))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    Spacer()
                    ZStack {
                        DemoBoardView()
                        PiecesLayer()
                    }
                    .padding(manager.deviceType == .iPad ? 40 : 20)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay {
                        BoardCoordinatesView(
                            squareSize: manager.squareDimension
                        )
                    }
                    .frame(width:boardSize,height: boardSize)
                    Spacer()
                    // Explanation
                    VStack(spacing: 6) {
                        Text(demo.instructions)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.75))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Controls
                    HStack {
                        Button("Reset Demo") {
                            manager.lastMove = nil
                            demo.loadPosition(manager)
                        }
                        .buttonStyle(.borderedProminent)
                        .foregroundColor(.white)
                        .foregroundStyle(.black)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .onAppear {
                    manager.squareDimension = geo.size.width * 0.90 / 8
                    manager.playFace2Face = false
                    manager.lastMove = nil
                    demo.loadPosition(manager)
                    manager.isDemoMode = true
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

