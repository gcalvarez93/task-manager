//
//  LoginWithGoogleUseCase.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Auth/Domain/UseCases/LoginWithGoogleUseCase.swift
import Foundation

final class LoginWithGoogleUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> UserEntity {
        try await repository.loginWithGoogle()
    }
}
