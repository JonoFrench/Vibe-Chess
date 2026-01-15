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
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [.black, .gray.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

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

                    // Board
                    ZStack {
                        DemoBoardView()
                        PiecesLayer()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)

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
                .padding(.top, 24)
                .onAppear {
                    manager.squareDimension = geo.size.width * 0.85 / 8
                    manager.lastMove = nil
                    demo.loadPosition(manager)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

