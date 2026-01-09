//
//  MoveListView.swift
//  Vibe-Chess
//
//  Created by Jonathan French on 7.01.26.
//

import SwiftUI

struct MoveRow {
    let moveNumber: Int
    let white: MoveRecord?
    let black: MoveRecord?
}


struct MoveListView: View {
    @EnvironmentObject var manager: GameManager
    
    private var rows: [MoveRow] {
        var result: [MoveRow] = []
        
        let moves = manager.moveHistory
        var i = 0
        
        while i < moves.count {
            let white = moves[i]
            let black = i + 1 < moves.count ? moves[i + 1] : nil
            
            result.append(
                MoveRow(
                    moveNumber: i / 2 + 1,
                    white: white,
                    black: black
                )
            )
            i += 2
        }
        
        return result
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(rows, id: \.moveNumber) { row in
                        HStack {
                            Text("\(row.moveNumber).").foregroundColor(.white)
                                .frame(width: 40, alignment: .trailing)
                            
                            Text(row.white.map { SANFormatter.san(for: $0) } ?? "").foregroundColor(.white)
                                .onTapGesture {
                                    if let white = row.white {
                                        manager.undo(toMoveIndex: moveIndex(of: white))
                                    }
                                }
                            
                            Text(row.black.map { SANFormatter.san(for: $0) } ?? "").foregroundColor(.white)
                                .onTapGesture {
                                    if let black = row.black {
                                        manager.undo(toMoveIndex: moveIndex(of: black))
                                    }
                                }
                            //                                .background(
                            //                                    manager.moveHistory.last?.id == $0.id
                            //                                        ? Color.blue.opacity(0.2)
                            //                                        : Color.clear
                            //                                )
                            
                        }
                        .font(.system(.body, design: .monospaced))
                        .id(row.moveNumber)
                    }
                }
                .padding()
            }.onChange(of: manager.moveHistory.count) {
                scrollToLatestMove(proxy)
            }
            
        }
        
    }
    
    private func scrollToLatestMove(_ proxy: ScrollViewProxy) {
        guard let last = rows.last else { return }
        
        withAnimation(.easeOut(duration: 0.25)) {
            proxy.scrollTo(last.moveNumber, anchor: .bottom)
        }
    }
    
    private func moveIndex(of record: MoveRecord) -> Int {
        manager.moveHistory.firstIndex { $0.id == record.id }!
    }
    
}

struct MoveRowView: View {
    let moveNumber: Int
    let white: MoveRecord?
    let black: MoveRecord?
    let isCurrent: Bool

    var body: some View {
        HStack(spacing: 12) {

            Text("\(moveNumber).")
                .foregroundStyle(.secondary)
                .frame(width: 28, alignment: .trailing)

            sanText(white)
            sanText(black)

            Spacer()
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
        .background(isCurrent ? Color.blue.opacity(0.15) : .clear)
        .cornerRadius(6)
    }

    private func sanText(_ record: MoveRecord?) -> some View {
        Text(record?.sanString() ?? "")
            .font(.system(.body, design: .monospaced))
            .frame(width: 80, alignment: .leading)
    }
}
