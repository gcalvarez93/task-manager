//
//  LoginWithEmailUseCase.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Auth/Domain/UseCases/LoginWithEmailUseCase.swift
import Foundation

final class LoginWithEmailUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(email: String, password: String) async throws -> UserEntity {
        try await repository.loginWithEmail(email: email, password: password)
    }
}
