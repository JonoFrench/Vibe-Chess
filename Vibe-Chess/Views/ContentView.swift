//
//  ContentView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 30.12.25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var manager: GameManager
    var body: some View {
        GeometryReader { geo in
        ZStack(alignment: .center) {
            Color.red.ignoresSafeArea()
            NavigationStack {
                    NavigationLink {
                        ChessView()
                    } label: {
                        VStack(spacing: 20) {
                            Text("Vibe Chess").font(.largeTitle)
                            Image(systemName: "globe")
                                .imageScale(.large)
                                .foregroundStyle(.tint)
                            Text("Tap to Play").font(.title)
                                .redacted(reason: [])
                        }.background(.yellow)
                    }
                    //}
                    .onAppear{
                        self.manager.squareDimension = geo.size.width / 8
                    }
                }
            }
        }
    }
}

#Preview {
    let previewEnvObject = GameManager()
    ContentView()
        .environmentObject(previewEnvObject)
}
