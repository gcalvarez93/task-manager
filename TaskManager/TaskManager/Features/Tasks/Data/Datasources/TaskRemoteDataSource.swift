//
//  TaskRemoteDataSource.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Tasks/Data/DataSources/TaskRemoteDataSource.swift
import Foundation

protocol TaskRemoteDataSourceProtocol {
    func getTasks(boardId: String) async throws -> [TaskModel]
    func createTask(_ request: CreateTaskRequest) async throws -> TaskModel
    func updateTask(id: String, request: UpdateTaskRequest) async throws -> TaskModel
    func deleteTask(id: String) async throws
}

final class TaskRemoteDataSource: TaskRemoteDataSourceProtocol {
    private let client: NetworkClientProtocol

    init(client: NetworkClientProtocol = NetworkClient.shared) {
        self.client = client
    }

    func getTasks(boardId: String) async throws -> [TaskModel] {
        try await client.get(APIConfig.tasksByBoard(boardId))
    }

    func createTask(_ request: CreateTaskRequest) async throws -> TaskModel {
        try await client.post(APIConfig.tasks, body: request)
    }

    func updateTask(id: String, request: UpdateTaskRequest) async throws -> TaskModel {
        try await client.put(APIConfig.task(id), body: request)
    }

    func deleteTask(id: String) async throws {
        try await client.delete(APIConfig.task(id))
    }
}
