//
//  TaskStatusBadge.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Tasks/Presentation/Components/TaskStatusBadge.swift
import SwiftUI

struct TaskStatusBadge: View {
    let status: TaskStatus

    private var color: Color {
        switch status {
        case .todo:       return .blue
        case .inProgress: return .orange
        case .done:       return .green
        }
    }

    private var label: String {
        switch status {
        case .todo:       return String(localized: "status_todo")
        case .inProgress: return String(localized: "status_in_progress")
        case .done:       return String(localized: "status_done")
        }
    }

    private var icon: String {
        switch status {
        case .todo:       return "circle"
        case .inProgress: return "clock"
        case .done:       return "checkmark.circle.fill"
        }
    }

    var body: some View {
        Label(label, systemImage: icon)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

#Preview {
    VStack {
        TaskStatusBadge(status: .todo)
        TaskStatusBadge(status: .inProgress)
        TaskStatusBadge(status: .done)
    }
    .padding()
}
