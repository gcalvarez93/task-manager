// Path: TaskManager/TaskManagerTests/Fakes/TestData.swift
import Foundation
@testable import TaskManager

@MainActor
enum TestData {
    static let referenceDate = Date(timeIntervalSince1970: 1_700_000_000)

    static let user = UserEntity(id: "u1", email: "ana@test.com", name: "Ana", photoUrl: nil)

    static let board = BoardEntity(
        id: "b1",
        name: "Trabajo",
        description: "Tareas del trabajo",
        color: "#7C3AED",
        taskCount: 2,
        createdAt: referenceDate
    )

    static let task = TaskEntity(
        id: "t1",
        boardId: "b1",
        title: "Preparar demo",
        description: "Revisar el flujo completo",
        priority: .high,
        status: .todo,
        dueDate: nil,
        labels: ["demo"],
        createdAt: referenceDate
    )

    static let profile = ProfileEntity(
        id: "u1",
        name: "Ana",
        email: "ana@test.com",
        photoUrl: nil,
        language: "es",
        notifications: true
    )
}
