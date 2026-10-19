// Path: TaskManager/TaskManagerTests/AuthViewModelTests.swift
import Testing
@testable import TaskManager

@MainActor
struct AuthViewModelTests {
    private let repository = FakeAuthRepository()

    private func makeViewModel() -> AuthViewModel {
        AuthViewModel(
            loginWithEmail: LoginWithEmailUseCase(repository: repository),
            registerWithEmail: RegisterWithEmailUseCase(repository: repository),
            loginWithGoogle: LoginWithGoogleUseCase(repository: repository),
            logout: LogoutUseCase(repository: repository),
            updateDisplayName: UpdateDisplayNameUseCase(repository: repository),
            repository: repository
        )
    }

    @Test func startsAuthenticatedWhenThereIsASession() {
        repository.signedInUser = TestData.user

        #expect(makeViewModel().state == .authenticated(TestData.user))
    }

    @Test func startsUnauthenticatedWithoutSession() {
        #expect(makeViewModel().state == .unauthenticated)
    }

    @Test func successfulLoginLeavesTheUserAuthenticated() async {
        let viewModel = makeViewModel()

        await viewModel.signInWithEmail(email: "ana@test.com", password: "123456")

        #expect(viewModel.state == .authenticated(TestData.user))
    }

    @Test func failedLoginExposesTheAuthMessage() async {
        repository.loginResult = .failure(.auth("Wrong password"))
        let viewModel = makeViewModel()

        await viewModel.signInWithEmail(email: "ana@test.com", password: "bad")

        #expect(viewModel.state == .error("Wrong password"))
    }

    @Test func signOutLeavesTheUserUnauthenticated() async {
        repository.signedInUser = TestData.user
        let viewModel = makeViewModel()

        await viewModel.signOut()

        #expect(viewModel.state == .unauthenticated)
    }

    @Test func failedSignOutKeepsTheErrorMessage() async {
        repository.signedInUser = TestData.user
        repository.logoutResult = .failure(.auth("Sign out failed"))
        let viewModel = makeViewModel()

        await viewModel.signOut()

        #expect(viewModel.state == .error("Sign out failed"))
    }

    @Test func updateDisplayNameReturnsTrueAndPublishesTheUser() async {
        let renamed = UserEntity(id: "u1", email: "ana@test.com", name: "Nuevo nombre", photoUrl: nil)
        repository.signedInUser = TestData.user
        repository.updateNameResult = .success(renamed)
        let viewModel = makeViewModel()

        let saved = await viewModel.updateDisplayName("Nuevo nombre")

        #expect(saved)
        #expect(viewModel.state == .authenticated(renamed))
    }

    @Test func failedUpdateDisplayNameKeepsTheSession() async {
        repository.signedInUser = TestData.user
        repository.updateNameResult = .failure(.auth("network"))
        let viewModel = makeViewModel()

        let saved = await viewModel.updateDisplayName("Nuevo nombre")

        #expect(!saved)
        #expect(viewModel.state == .authenticated(TestData.user))
    }
}
