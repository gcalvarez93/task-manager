// Path: TaskManager/TaskManagerTests/AuthRepositoryTests.swift
import Testing
@testable import TaskManager

@MainActor
struct AuthRepositoryTests {
    private let dataSource = FakeAuthRemoteDataSource()

    private func makeRepository() -> AuthRepository {
        AuthRepository(dataSource: dataSource)
    }

    @Test func updateDisplayNameReturnsTheUpdatedUser() async throws {
        dataSource.updatedUser = UserModel(id: "u1", email: "ana@test.com", name: "Nuevo", photoUrl: nil)

        let user = try await makeRepository().updateDisplayName("Nuevo")

        #expect(user.name == "Nuevo")
    }

    @Test func updateDisplayNameWithoutSessionThrowsAnAuthFailure() async {
        dataSource.updatedUser = nil

        await #expect(throws: Failure.auth("No active session")) {
            _ = try await makeRepository().updateDisplayName("Nuevo")
        }
    }

    @Test func getCurrentUserIsNilWithoutSession() {
        #expect(makeRepository().getCurrentUser() == nil)
    }

    @Test func getCurrentUserMapsTheModel() {
        dataSource.currentUser = UserModel(id: "u9", email: "x@y.com", name: "Eva", photoUrl: nil)

        let user = makeRepository().getCurrentUser()

        #expect(user == UserEntity(id: "u9", email: "x@y.com", name: "Eva", photoUrl: nil))
    }
}
