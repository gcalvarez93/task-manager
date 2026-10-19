// Path: TaskManager/TaskManagerTests/Fakes/FakeRepositories.swift
import Foundation
@testable import TaskManager

/// Repositorio de autenticación en memoria con resultados configurables.
@MainActor
final class FakeAuthRepository: AuthRepositoryProtocol {
    var signedInUser: UserEntity?
    var loginResult: Result<UserEntity, Failure> = .success(TestData.user)
    var updateNameResult: Result<UserEntity, Failure> = .success(TestData.user)
    var logoutResult: Result<Void, Failure> = .success(())

    func loginWithEmail(email: String, password: String) async throws -> UserEntity {
        try loginResult.get()
    }

    func registerWithEmail(email: String, password: String, name: String) async throws -> UserEntity {
        try loginResult.get()
    }

    func loginWithGoogle() async throws -> UserEntity {
        try loginResult.get()
    }

    func logout() async throws {
        try logoutResult.get()
        signedInUser = nil
    }

    func updateDisplayName(_ name: String) async throws -> UserEntity {
        try updateNameResult.get()
    }

    func getCurrentUser() -> UserEntity? {
        signedInUser
    }
}

@MainActor
final class FakeBoardRepository: BoardRepositoryProtocol {
    var boardsResult: Result<[BoardEntity], Failure> = .success([])
    var createResult: Result<BoardEntity, Failure> = .success(TestData.board)
    var updateResult: Result<BoardEntity, Failure> = .success(TestData.board)
    var deleteResult: Result<Void, Failure> = .success(())

    private(set) var getBoardsCalls = 0
    private(set) var deletedId: String?

    func getBoards() async throws -> [BoardEntity] {
        getBoardsCalls += 1
        return try boardsResult.get()
    }

    func createBoard(name: String, description: String, color: String) async throws -> BoardEntity {
        try createResult.get()
    }

    func updateBoard(id: String, name: String, description: String, color: String) async throws -> BoardEntity {
        try updateResult.get()
    }

    func deleteBoard(id: String) async throws {
        deletedId = id
        try deleteResult.get()
    }
}

@MainActor
final class FakeTaskRepository: TaskRepositoryProtocol {
    var tasksResult: Result<[TaskEntity], Failure> = .success([])
    var createResult: Result<TaskEntity, Failure> = .success(TestData.task)
    var updateResult: Result<TaskEntity, Failure> = .success(TestData.task)
    var deleteResult: Result<Void, Failure> = .success(())

    private(set) var getTasksCalls = 0
    private(set) var deletedId: String?
    private(set) var updatedId: String?

    func getTasks(boardId: String) async throws -> [TaskEntity] {
        getTasksCalls += 1
        return try tasksResult.get()
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
        try createResult.get()
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
        updatedId = id
        return try updateResult.get()
    }

    func deleteTask(id: String) async throws {
        deletedId = id
        try deleteResult.get()
    }
}

@MainActor
final class FakeProfileRepository: ProfileRepositoryProtocol {
    var profileResult: Result<ProfileEntity, Failure> = .success(TestData.profile)
    var updateResult: Result<ProfileEntity, Failure>?

    func getProfile() async throws -> ProfileEntity {
        try profileResult.get()
    }

    func updateProfile(name: String, language: String, notifications: Bool) async throws -> ProfileEntity {
        if let updateResult {
            return try updateResult.get()
        }
        return ProfileEntity(
            id: TestData.profile.id,
            name: name,
            email: TestData.profile.email,
            photoUrl: nil,
            language: language,
            notifications: notifications
        )
    }
}
