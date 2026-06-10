//
//  ProfileRepository.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Profile/Data/Repositories/ProfileRepository.swift
import Foundation

final class ProfileRepository: ProfileRepositoryProtocol {
    private let dataSource: ProfileRemoteDataSourceProtocol

    init(dataSource: ProfileRemoteDataSourceProtocol = ProfileRemoteDataSource()) {
        self.dataSource = dataSource
    }

    func getProfile() async throws -> ProfileEntity {
        let model = try await dataSource.getProfile()
        return model.toEntity()
    }

    func updateProfile(name: String, language: String, notifications: Bool) async throws -> ProfileEntity {
        let model = try await dataSource.updateProfile(
            name: name,
            language: language,
            notifications: notifications
        )
        return model.toEntity()
    }
}
