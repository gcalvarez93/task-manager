//
//  BoardEntity.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Boards/Domain/Entities/BoardEntity.swift
import Foundation

struct BoardEntity: Equatable, Identifiable {
    let id: String
    let name: String
    let description: String
    let color: String
    let taskCount: Int
    let createdAt: Date
}
