//
//  TaskEntity.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Tasks/Domain/Entities/TaskEntity.swift
import Foundation

enum TaskPriority: String, Codable, CaseIterable {
    case low
    case medium
    case high
}

enum TaskStatus: String, Codable, CaseIterable {
    case todo
    case inProgress
    case done
}

struct TaskEntity: Equatable, Identifiable {
    let id: String
    let boardId: String
    let title: String
    let description: String
    let priority: TaskPriority
    let status: TaskStatus
    let dueDate: Date?
    let labels: [String]
    let createdAt: Date
}
