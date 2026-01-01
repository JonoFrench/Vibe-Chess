//
//  MoveHighLightView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 30.12.25.
//

import Foundation
import SwiftUI

struct MoveHighlightView: View {
    let isCapture: Bool
    let size: CGFloat

    var body: some View {
        Circle()
            .strokeBorder(
                isCapture ? Color.red : Color.blue,
                lineWidth: isCapture ? 4 : 0
            )
            .background(
                Circle()
                    .fill(isCapture ? Color.clear
                                    : Color.blue.opacity(0.35))
            )
            .frame(
                width: isCapture ? size * 0.85 : size * 0.35,
                height: isCapture ? size * 0.85 : size * 0.35
            )
            .scaleEffect(0.8)
            .opacity(0)
            .transition(
                .scale(scale: 0.5)
                .combined(with: .opacity)
            )
    }
}
