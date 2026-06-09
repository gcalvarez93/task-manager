//
//  BoardRepository.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Boards/Data/Repositories/BoardRepository.swift
import Foundation

final class BoardRepository: BoardRepositoryProtocol {
    private let dataSource: BoardRemoteDataSourceProtocol

    init(dataSource: BoardRemoteDataSourceProtocol = BoardRemoteDataSource()) {
        self.dataSource = dataSource
    }

    func getBoards() async throws -> [BoardEntity] {
        let models = try await dataSource.getBoards()
        return models.map { $0.toEntity() }
    }

    func createBoard(name: String, description: String, color: String) async throws -> BoardEntity {
        let model = try await dataSource.createBoard(name: name, description: description, color: color)
        return model.toEntity()
    }

    func updateBoard(id: String, name: String, description: String, color: String) async throws -> BoardEntity {
        let model = try await dataSource.updateBoard(id: id, name: name, description: description, color: color)
        return model.toEntity()
    }

    func deleteBoard(id: String) async throws {
        try await dataSource.deleteBoard(id: id)
    }
}
