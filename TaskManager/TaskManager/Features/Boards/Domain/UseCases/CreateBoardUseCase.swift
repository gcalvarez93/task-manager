//
//  CreateBoardUseCase.swift.swift
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
        try await repository.createBoard(name: name, description: description, color: color)
    }
}
