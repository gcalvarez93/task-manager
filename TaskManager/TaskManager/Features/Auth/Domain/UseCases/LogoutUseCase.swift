//
//  LogoutUseCase.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Auth/Domain/UseCases/LogoutUseCase.swift
import Foundation

final class LogoutUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws {
        try await repository.logout()
    }
}
