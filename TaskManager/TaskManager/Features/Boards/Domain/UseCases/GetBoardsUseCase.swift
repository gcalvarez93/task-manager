//
//  GetBoardsUseCase.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Boards/Domain/UseCases/GetBoardsUseCase.swift
import Foundation

final class GetBoardsUseCase {
    private let repository: BoardRepositoryProtocol

    init(repository: BoardRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [BoardEntity] {
        try await repository.getBoards()
    }
}
