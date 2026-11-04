//
//  UpdateBoardUseCase.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Boards/Domain/UseCases/UpdateBoardUseCase.swift
import Foundation

final class UpdateBoardUseCase {
    private let repository: BoardRepositoryProtocol

    init(repository: BoardRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: String, name: String, description: String, color: String) async throws -> BoardEntity {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { throw Failure.validation(String(localized: "validation_name_empty")) }
        return try await repository.updateBoard(id: id, name: name, description: description, color: color)
    }
}
