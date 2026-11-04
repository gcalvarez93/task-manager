//
//  CreateTaskUseCase.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Tasks/Domain/UseCases/CreateTaskUseCase.swift
import Foundation

final class CreateTaskUseCase {
    private let repository: TaskRepositoryProtocol

    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        boardId: String,
        title: String,
        description: String,
        priority: TaskPriority,
        status: TaskStatus,
        dueDate: Date?,
        labels: [String]
    ) async throws -> TaskEntity {
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { throw Failure.validation(String(localized: "validation_title_empty")) }
        return try await repository.createTask(
            boardId: boardId,
            title: title,
            description: description,
            priority: priority,
            status: status,
            dueDate: dueDate,
            labels: labels
        )
    }
}
