//
//  GetProfileUseCase.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Profile/Domain/UseCases/GetProfileUseCase.swift
import Foundation

final class GetProfileUseCase {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> ProfileEntity {
        try await repository.getProfile()
    }
}
