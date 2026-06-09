//
//  AuthRepository.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Auth/Data/Repositories/AuthRepository.swift
import Foundation

final class AuthRepository: AuthRepositoryProtocol {
    private let dataSource: AuthRemoteDataSourceProtocol

    init(dataSource: AuthRemoteDataSourceProtocol = AuthRemoteDataSource()) {
        self.dataSource = dataSource
    }

    func loginWithEmail(email: String, password: String) async throws -> UserEntity {
        let model = try await dataSource.loginWithEmail(email: email, password: password)
        return model.toEntity()
    }

    func registerWithEmail(email: String, password: String, name: String) async throws -> UserEntity {
        let model = try await dataSource.registerWithEmail(email: email, password: password, name: name)
        return model.toEntity()
    }

    func loginWithGoogle() async throws -> UserEntity {
        let model = try await dataSource.loginWithGoogle()
        return model.toEntity()
    }

    func logout() async throws {
        try await dataSource.logout()
    }

    func getCurrentUser() -> UserEntity? {
        dataSource.getCurrentUser()?.toEntity()
    }
}
