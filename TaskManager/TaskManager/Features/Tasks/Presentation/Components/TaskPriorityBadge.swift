//
//  TaskPriorityBadge.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Tasks/Presentation/Components/TaskPriorityBadge.swift
import SwiftUI

struct TaskPriorityBadge: View {
    let priority: TaskPriority

    private var color: Color {
        switch priority {
        case .low:    return .green
        case .medium: return .orange
        case .high:   return .red
        }
    }

    private var label: String {
        switch priority {
        case .low:    return String(localized: "priority_low")
        case .medium: return String(localized: "priority_medium")
        case .high:   return String(localized: "priority_high")
        }
    }

    var body: some View {
        Text(label)
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
    HStack {
        TaskPriorityBadge(priority: .low)
        TaskPriorityBadge(priority: .medium)
        TaskPriorityBadge(priority: .high)
    }
    .padding()
}
