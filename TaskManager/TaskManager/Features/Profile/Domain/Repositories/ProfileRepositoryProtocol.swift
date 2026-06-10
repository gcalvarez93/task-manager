//
//  ProfileRepositoryProtocol.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Profile/Domain/Repositories/ProfileRepositoryProtocol.swift
import Foundation

protocol ProfileRepositoryProtocol {
    func getProfile() async throws -> ProfileEntity
    func updateProfile(name: String, language: String, notifications: Bool) async throws -> ProfileEntity
}
