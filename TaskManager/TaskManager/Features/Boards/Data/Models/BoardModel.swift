//
//  BoardModel.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Boards/Data/Models/BoardModel.swift
import Foundation

struct BoardModel: Codable {
    let id: String
    let name: String
    let description: String
    let color: String
    let taskCount: Int
    let createdAt: Date

    func toEntity() -> BoardEntity {
        BoardEntity(
            id: id,
            name: name,
            description: description,
            color: color,
            taskCount: taskCount,
            createdAt: createdAt
        )
    }
}

struct CreateBoardRequest: Encodable {
    let name: String
    let description: String
    let color: String
}
