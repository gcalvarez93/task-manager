//
//  BoardCardView.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Boards/Presentation/Components/BoardCardView.swift
import SwiftUI

struct BoardCardView: View {
    let board: BoardEntity

    private var color: Color {
        Color(hex: board.color) ?? .blue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(width: 40, height: 40)
                Spacer()
                Text("\(board.taskCount)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Image(systemName: "checkmark.square")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(board.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                if !board.description.isEmpty {
                    Text(board.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}
