//
//  ClockView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 11.01.26.
//

import SwiftUI

struct ClockView: View {
    let time: TimeInterval?
    let isActive: Bool

    var body: some View {
        if let time {
            Text(formatTime(time))
                .font(.system(.title2, design: .monospaced))
                .foregroundColor(isActive ? .green : .white)
                .padding(8)
                .background(isActive ? Color.black.opacity(0.4) : Color.clear)
                .cornerRadius(8)
        } else {
            Text(formatTime(time))
                .font(.system(.title, design: .monospaced))
                .foregroundColor(isActive ? .green : .white)
                .padding(8)
                .background(isActive ? Color.black.opacity(0.4) : Color.clear)
                .cornerRadius(8)

        }
    }

    private func formatTime(_ t: TimeInterval?) -> String {
        if let t {
            let m = Int(t) / 60
            let s = Int(t) % 60
            return String(format: "%02d:%02d", m, s)
        } else {
            return "  ∞  "  
        }
    }
}
