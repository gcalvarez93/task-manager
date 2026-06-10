//
//  TaskRepositoryProtocol.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Tasks/Domain/Repositories/TaskRepositoryProtocol.swift
import Foundation

protocol TaskRepositoryProtocol {
    func getTasks(boardId: String) async throws -> [TaskEntity]
    func createTask(boardId: String, title: String, description: String, priority: TaskPriority, status: TaskStatus, dueDate: Date?, labels: [String]) async throws -> TaskEntity
    func updateTask(id: String, title: String, description: String, priority: TaskPriority, status: TaskStatus, dueDate: Date?, labels: [String]) async throws -> TaskEntity
    func deleteTask(id: String) async throws
}
