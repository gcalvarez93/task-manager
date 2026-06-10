//
//  GetTasksUseCase.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Tasks/Domain/UseCases/GetTasksUseCase.swift
import Foundation

final class GetTasksUseCase {
    private let repository: TaskRepositoryProtocol

    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }

    func execute(boardId: String) async throws -> [TaskEntity] {
        try await repository.getTasks(boardId: boardId)
    }
}
