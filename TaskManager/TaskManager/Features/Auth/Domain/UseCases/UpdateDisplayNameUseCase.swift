//
//  UpdateDisplayNameUseCase.swift
//  TaskManager
//
//  Created by Gabriel Castro on 19/10/2026.
//

// Path: TaskManager/Features/Auth/Domain/UseCases/UpdateDisplayNameUseCase.swift
import Foundation

final class UpdateDisplayNameUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(name: String) async throws -> UserEntity {
        try await repository.updateDisplayName(name)
    }
}
