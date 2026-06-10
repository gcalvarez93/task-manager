//
//  TaskRepository.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Tasks/Data/Repositories/TaskRepository.swift
import Foundation

final class TaskRepository: TaskRepositoryProtocol {
    private let dataSource: TaskRemoteDataSourceProtocol

    init(dataSource: TaskRemoteDataSourceProtocol = TaskRemoteDataSource()) {
        self.dataSource = dataSource
    }

    func getTasks(boardId: String) async throws -> [TaskEntity] {
        let models = try await dataSource.getTasks(boardId: boardId)
        return models.map { $0.toEntity() }
    }

    func createTask(
        boardId: String,
        title: String,
        description: String,
        priority: TaskPriority,
        status: TaskStatus,
        dueDate: Date?,
        labels: [String]
    ) async throws -> TaskEntity {
        let request = CreateTaskRequest(
            boardId: boardId,
            title: title,
            description: description,
            priority: priority.rawValue,
            status: status.rawValue,
            dueDate: dueDate,
            labels: labels
        )
        let model = try await dataSource.createTask(request)
        return model.toEntity()
    }

    func updateTask(
        id: String,
        title: String,
        description: String,
        priority: TaskPriority,
        status: TaskStatus,
        dueDate: Date?,
        labels: [String]
    ) async throws -> TaskEntity {
        let request = UpdateTaskRequest(
            title: title,
            description: description,
            priority: priority.rawValue,
            status: status.rawValue,
            dueDate: dueDate,
            labels: labels
        )
        let model = try await dataSource.updateTask(id: id, request: request)
        return model.toEntity()
    }

    func deleteTask(id: String) async throws {
        try await dataSource.deleteTask(id: id)
    }
}
