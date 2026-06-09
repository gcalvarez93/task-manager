//
//  DeleteBoardUseCase.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Boards/Domain/UseCases/DeleteBoardUseCase.swift
import Foundation

final class DeleteBoardUseCase {
    private let repository: BoardRepositoryProtocol

    init(repository: BoardRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: String) async throws {
        try await repository.deleteBoard(id: id)
    }
}
