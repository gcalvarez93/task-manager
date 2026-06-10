//
//  UpdateTaskUseCase.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Tasks/Domain/UseCases/UpdateTaskUseCase.swift
import Foundation

final class UpdateTaskUseCase {
    private let repository: TaskRepositoryProtocol

    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        id: String,
        title: String,
        description: String,
        priority: TaskPriority,
        status: TaskStatus,
        dueDate: Date?,
        labels: [String]
    ) async throws -> TaskEntity {
        try await repository.updateTask(
            id: id,
            title: title,
            description: description,
            priority: priority,
            status: status,
            dueDate: dueDate,
            labels: labels
        )
    }
}
