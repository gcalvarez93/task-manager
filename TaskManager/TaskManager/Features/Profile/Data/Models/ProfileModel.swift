//
//  ProfileModel.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Profile/Data/Models/ProfileModel.swift
import Foundation

struct ProfileModel: Codable {
    let id: String
    let name: String
    let email: String
    let photoUrl: String?
    let language: String
    let notifications: Bool

    func toEntity() -> ProfileEntity {
        ProfileEntity(
            id: id,
            name: name,
            email: email,
            photoUrl: photoUrl,
            language: language,
            notifications: notifications
        )
    }
}

struct UpdateProfileRequest: Encodable {
    let name: String
    let language: String
    let notifications: Bool
    let photoUrl: String
}
