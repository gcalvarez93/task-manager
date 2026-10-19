// Path: TaskManager/TaskManagerTests/Fakes/FakeDataSources.swift
import Foundation
@testable import TaskManager

@MainActor
final class FakeTaskRemoteDataSource: TaskRemoteDataSourceProtocol {
    var tasks: [TaskModel] = []
    var error: Failure?

    private(set) var lastCreateRequest: CreateTaskRequest?
    private(set) var lastUpdateRequest: UpdateTaskRequest?

    func getTasks(boardId: String) async throws -> [TaskModel] {
        if let error { throw error }
        return tasks
    }

    func createTask(_ request: CreateTaskRequest) async throws -> TaskModel {
        if let error { throw error }
        lastCreateRequest = request
        return TaskModel(
            id: "t-new",
            boardId: request.boardId,
            title: request.title,
            description: request.description,
            priority: request.priority,
            status: request.status,
            dueDate: request.dueDate,
            labels: request.labels,
            createdAt: TestData.referenceDate
        )
    }

    func updateTask(id: String, request: UpdateTaskRequest) async throws -> TaskModel {
        if let error { throw error }
        lastUpdateRequest = request
        return TaskModel(
            id: id,
            boardId: "b1",
            title: request.title,
            description: request.description,
            priority: request.priority,
            status: request.status,
            dueDate: request.dueDate,
            labels: request.labels,
            createdAt: TestData.referenceDate
        )
    }

    func deleteTask(id: String) async throws {
        if let error { throw error }
    }
}

@MainActor
final class FakeAuthRemoteDataSource: AuthRemoteDataSourceProtocol {
    var updatedUser: UserModel?
    var error: Failure?
    var currentUser: UserModel?

    func loginWithEmail(email: String, password: String) async throws -> UserModel {
        if let error { throw error }
        return UserModel(id: "u1", email: email, name: nil, photoUrl: nil)
    }

    func registerWithEmail(email: String, password: String, name: String) async throws -> UserModel {
        if let error { throw error }
        return UserModel(id: "u1", email: email, name: name, photoUrl: nil)
    }

    func loginWithGoogle() async throws -> UserModel {
        if let error { throw error }
        return UserModel(id: "u1", email: "ana@test.com", name: "Ana", photoUrl: nil)
    }

    func logout() async throws {
        if let error { throw error }
    }

    func updateDisplayName(_ name: String) async throws -> UserModel? {
        if let error { throw error }
        return updatedUser
    }

    func getCurrentUser() -> UserModel? {
        currentUser
    }
}
