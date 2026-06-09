//
//  UserModel.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Auth/Data/Models/UserModel.swift
import Foundation

struct UserModel: Codable {
    let id: String
    let email: String
    let name: String?
    let photoUrl: String?

    func toEntity() -> UserEntity {
        UserEntity(
            id: id,
            email: email,
            name: name,
            photoUrl: photoUrl
        )
    }
}
