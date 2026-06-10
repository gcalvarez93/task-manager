//
//  TaskModel.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Tasks/Data/Models/TaskModel.swift
import Foundation

struct TaskModel: Codable {
    let id: String
    let boardId: String
    let title: String
    let description: String
    let priority: String
    let status: String
    let dueDate: Date?
    let labels: [String]
    let createdAt: Date

    func toEntity() -> TaskEntity {
        TaskEntity(
            id: id,
            boardId: boardId,
            title: title,
            description: description,
            priority: TaskPriority(rawValue: priority) ?? .medium,
            status: TaskStatus(rawValue: status) ?? .todo,
            dueDate: dueDate,
            labels: labels,
            createdAt: createdAt
        )
    }
}

struct CreateTaskRequest: Encodable {
    let boardId: String
    let title: String
    let description: String
    let priority: String
    let status: String
    let dueDate: Date?
    let labels: [String]
}

struct UpdateTaskRequest: Encodable {
    let title: String
    let description: String
    let priority: String
    let status: String
    let dueDate: Date?
    let labels: [String]
}
