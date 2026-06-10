//
//  TaskRowView.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Tasks/Presentation/Components/TaskRowView.swift
import SwiftUI

struct TaskRowView: View {
    let task: TaskEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(task.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Spacer()
                TaskPriorityBadge(priority: task.priority)
            }

            if !task.description.isEmpty {
                Text(task.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack {
                TaskStatusBadge(status: task.status)
                Spacer()
                if let dueDate = task.dueDate {
                    Label(dueDate.formatted(date: .abbreviated, time: .omitted),
                          systemImage: "calendar")
                        .font(.caption2)
                        .foregroundStyle(dueDate < Date() ? .red : .secondary)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    TaskRowView(task: TaskEntity(
        id: "1",
        boardId: "board1",
        title: "Design new dashboard",
        description: "Create wireframes and mockups for the new dashboard layout",
        priority: .high,
        status: .inProgress,
        dueDate: Date().addingTimeInterval(86400 * 2),
        labels: [],
        createdAt: Date()
    ))
    .padding()
}
