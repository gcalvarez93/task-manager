//
//  RegisterWithEmailUseCase.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Auth/Domain/UseCases/RegisterWithEmailUseCase.swift
import Foundation

final class RegisterWithEmailUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(email: String, password: String, name: String) async throws -> UserEntity {
        try await repository.registerWithEmail(email: email, password: password, name: name)
    }
}
