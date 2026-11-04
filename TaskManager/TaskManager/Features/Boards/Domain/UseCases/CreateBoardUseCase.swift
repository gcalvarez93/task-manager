//
//  CreateBoardUseCase.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Boards/Domain/UseCases/CreateBoardUseCase.swift
import Foundation

final class CreateBoardUseCase {
    private let repository: BoardRepositoryProtocol

    init(repository: BoardRepositoryProtocol) {
        self.repository = repository
    }

    func execute(name: String, description: String, color: String) async throws -> BoardEntity {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { throw Failure.validation(String(localized: "validation_name_empty")) }
        return try await repository.createBoard(name: name, description: description, color: color)
    }
}
