//
//  BoardRepositoryProtocol.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Boards/Domain/Repositories/BoardRepositoryProtocol.swift
import Foundation

protocol BoardRepositoryProtocol {
    func getBoards() async throws -> [BoardEntity]
    func createBoard(name: String, description: String, color: String) async throws -> BoardEntity
    func updateBoard(id: String, name: String, description: String, color: String) async throws -> BoardEntity
    func deleteBoard(id: String) async throws
}
