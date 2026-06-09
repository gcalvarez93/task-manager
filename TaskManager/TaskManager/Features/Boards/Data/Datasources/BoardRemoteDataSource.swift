//
//  BoardRemoteDataSource.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Boards/Data/DataSources/BoardRemoteDataSource.swift
import Foundation

protocol BoardRemoteDataSourceProtocol {
    func getBoards() async throws -> [BoardModel]
    func createBoard(name: String, description: String, color: String) async throws -> BoardModel
    func updateBoard(id: String, name: String, description: String, color: String) async throws -> BoardModel
    func deleteBoard(id: String) async throws
}

final class BoardRemoteDataSource: BoardRemoteDataSourceProtocol {
    private let client: NetworkClientProtocol

    init(client: NetworkClientProtocol = NetworkClient.shared) {
        self.client = client
    }

    func getBoards() async throws -> [BoardModel] {
        try await client.get(APIConfig.boards)
    }

    func createBoard(name: String, description: String, color: String) async throws -> BoardModel {
        let body = CreateBoardRequest(name: name, description: description, color: color)
        return try await client.post(APIConfig.boards, body: body)
    }

    func updateBoard(id: String, name: String, description: String, color: String) async throws -> BoardModel {
        let body = CreateBoardRequest(name: name, description: description, color: color)
        return try await client.put(APIConfig.board(id), body: body)
    }

    func deleteBoard(id: String) async throws {
        try await client.delete(APIConfig.board(id))
    }
}
