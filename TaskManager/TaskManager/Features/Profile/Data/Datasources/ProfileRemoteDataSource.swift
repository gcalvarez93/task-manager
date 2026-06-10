//
//  ProfileRemoteDataSource.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Profile/Data/DataSources/ProfileRemoteDataSource.swift
import Foundation

protocol ProfileRemoteDataSourceProtocol {
    func getProfile() async throws -> ProfileModel
    func updateProfile(name: String, language: String, notifications: Bool) async throws -> ProfileModel
}

final class ProfileRemoteDataSource: ProfileRemoteDataSourceProtocol {
    private let client: NetworkClientProtocol

    init(client: NetworkClientProtocol = NetworkClient.shared) {
        self.client = client
    }

    func getProfile() async throws -> ProfileModel {
        try await client.get(APIConfig.userMe)
    }

    func updateProfile(name: String, language: String, notifications: Bool) async throws -> ProfileModel {
        let body = UpdateProfileRequest(
            name: name,
            language: language,
            notifications: notifications,
            photoUrl: ""
        )
        return try await client.put(APIConfig.userMe, body: body)
    }
}
