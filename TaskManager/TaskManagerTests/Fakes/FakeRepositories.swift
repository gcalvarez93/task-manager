// Path: TaskManager/TaskManagerTests/Fakes/FakeRepositories.swift
import Foundation
@testable import TaskManager

/// Repositorio de autenticación en memoria con resultados configurables.
/// `googleError` permite simular errores que no son un `Failure` (por ejemplo, una cancelación).
@MainActor
final class FakeAuthRepository: AuthRepositoryProtocol {
    var signedInUser: UserEntity?
    var loginResult: Result<UserEntity, Failure> = .success(TestData.user)
    var updateNameResult: Result<UserEntity, Failure> = .success(TestData.user)
    var logoutResult: Result<Void, Failure> = .success(())
    var googleError: Error?

    func loginWithEmail(email: String, password: String) async throws -> UserEntity {
        try loginResult.get()
    }

    func registerWithEmail(email: String, password: String, name: String) async throws -> UserEntity {
        try loginResult.get()
    }

    func loginWithGoogle() async throws -> UserEntity {
        if let googleError { throw googleError }
        return try loginResult.get()
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

/// `boardsError` tiene prioridad sobre `boardsResult` y admite cualquier error (también cancelaciones).
@MainActor
final class FakeBoardRepository: BoardRepositoryProtocol {
    var boardsResult: Result<[BoardEntity], Failure> = .success([])
    var boardsError: Error?
    var createResult: Result<BoardEntity, Failure> = .success(TestData.board)
    var updateResult: Result<BoardEntity, Failure> = .success(TestData.board)
    var deleteResult: Result<Void, Failure> = .success(())
    var deleteError: Error?

    private(set) var getBoardsCalls = 0
    private(set) var createCalls = 0
    private(set) var updateCalls = 0
    private(set) var lastCreatedName: String?
    private(set) var lastUpdatedName: String?
    private(set) var deletedId: String?

    func getBoards() async throws -> [BoardEntity] {
        getBoardsCalls += 1
        if let boardsError { throw boardsError }
        return try boardsResult.get()
    }

    func createBoard(name: String, description: String, color: String) async throws -> BoardEntity {
        createCalls += 1
        lastCreatedName = name
        return try createResult.get()
    }

    func updateBoard(id: String, name: String, description: String, color: String) async throws -> BoardEntity {
        updateCalls += 1
        lastUpdatedName = name
        return try updateResult.get()
    }

    func deleteBoard(id: String) async throws {
        deletedId = id
        if let deleteError { throw deleteError }
        try deleteResult.get()
    }
}

/// `tasksError` tiene prioridad sobre `tasksResult` y admite cualquier error (también cancelaciones).
@MainActor
final class FakeTaskRepository: TaskRepositoryProtocol {
    var tasksResult: Result<[TaskEntity], Failure> = .success([])
    var tasksError: Error?
    var createResult: Result<TaskEntity, Failure> = .success(TestData.task)
    var updateResult: Result<TaskEntity, Failure> = .success(TestData.task)
    var deleteResult: Result<Void, Failure> = .success(())

    private(set) var getTasksCalls = 0
    private(set) var createCalls = 0
    private(set) var updateCalls = 0
    private(set) var lastCreatedTitle: String?
    private(set) var lastUpdatedTitle: String?
    private(set) var deletedId: String?
    private(set) var updatedId: String?

    func getTasks(boardId: String) async throws -> [TaskEntity] {
        getTasksCalls += 1
        if let tasksError { throw tasksError }
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
        createCalls += 1
        lastCreatedTitle = title
        return try createResult.get()
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
        updateCalls += 1
        updatedId = id
        lastUpdatedTitle = title
        return try updateResult.get()
    }

    func deleteTask(id: String) async throws {
        deletedId = id
        try deleteResult.get()
    }
}

/// `profileError` tiene prioridad sobre `profileResult` y admite cualquier error (también cancelaciones).
@MainActor
final class FakeProfileRepository: ProfileRepositoryProtocol {
    var profileResult: Result<ProfileEntity, Failure> = .success(TestData.profile)
    var profileError: Error?
    var updateResult: Result<ProfileEntity, Failure>?

    func getProfile() async throws -> ProfileEntity {
        if let profileError { throw profileError }
        return try profileResult.get()
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
