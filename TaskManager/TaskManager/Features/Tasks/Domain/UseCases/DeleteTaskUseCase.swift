//
//  DeleteTaskUseCase.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Tasks/Domain/UseCases/DeleteTaskUseCase.swift
import Foundation

final class DeleteTaskUseCase {
    private let repository: TaskRepositoryProtocol

    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: String) async throws {
        try await repository.deleteTask(id: id)
    }
}
