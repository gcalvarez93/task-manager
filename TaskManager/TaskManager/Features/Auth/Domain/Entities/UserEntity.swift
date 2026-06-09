//
//  UserEntity.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Auth/Domain/Entities/UserEntity.swift
import Foundation

struct UserEntity: Equatable {
    let id: String
    let email: String
    let name: String?
    let photoUrl: String?
}
