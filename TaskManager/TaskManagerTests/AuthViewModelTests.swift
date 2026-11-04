// Path: TaskManager/TaskManagerTests/AuthViewModelTests.swift
import Foundation
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

    // MARK: - Sesión inicial

    @Test func startsAuthenticatedWhenThereIsASession() {
        repository.signedInUser = TestData.user

        #expect(makeViewModel().state == .authenticated(TestData.user))
    }

    @Test func startsUnauthenticatedWithoutSession() {
        #expect(makeViewModel().state == .unauthenticated)
    }

    // MARK: - Inicio de sesión

    @Test func successfulLoginLeavesTheUserAuthenticated() async {
        let viewModel = makeViewModel()

        await viewModel.signInWithEmail(email: "ana@test.com", password: "123456")

        #expect(viewModel.state == .authenticated(TestData.user))
    }

    @Test func failedLoginExposesTheUserMessage() async {
        repository.loginResult = .failure(.invalidCredentials)
        let viewModel = makeViewModel()

        await viewModel.signInWithEmail(email: "ana@test.com", password: "bad")

        #expect(viewModel.state == .error(Failure.invalidCredentials.userMessage))
    }

    @Test func technicalDetailOfAuthFailuresDoesNotReachTheUser() async {
        repository.loginResult = .failure(.auth("Wrong password"))
        let viewModel = makeViewModel()

        await viewModel.signInWithEmail(email: "ana@test.com", password: "bad")

        guard case .error(let message) = viewModel.state else {
            Issue.record("Expected an error state")
            return
        }
        #expect(message == Failure.auth("Wrong password").userMessage)
        #expect(!message.contains("Wrong password"))
    }

    // MARK: - Registro

    @Test func failedRegistrationExposesTheUserMessage() async {
        repository.loginResult = .failure(.emailAlreadyInUse)
        let viewModel = makeViewModel()

        await viewModel.signUpWithEmail(email: "ana@test.com", password: "123456", name: "Ana")

        #expect(viewModel.state == .error(Failure.emailAlreadyInUse.userMessage))
    }

    // MARK: - Google

    @Test func cancellingGoogleSignInLeavesTheUserUnauthenticatedWithoutAnError() async {
        repository.googleError = CancellationError()
        let viewModel = makeViewModel()

        await viewModel.signInWithGoogle()

        #expect(viewModel.state == .unauthenticated)
    }

    // MARK: - Cerrar sesión

    @Test func signOutLeavesTheUserUnauthenticated() async {
        repository.signedInUser = TestData.user
        let viewModel = makeViewModel()

        let message = await viewModel.signOut()

        #expect(message == nil)
        #expect(viewModel.state == .unauthenticated)
    }

    @Test func failedSignOutKeepsTheSessionAndReturnsTheUserMessage() async {
        repository.signedInUser = TestData.user
        repository.logoutResult = .failure(.auth("Sign out failed"))
        let viewModel = makeViewModel()

        let message = await viewModel.signOut()

        #expect(message == Failure.auth("Sign out failed").userMessage)
        #expect(viewModel.state == .authenticated(TestData.user))
    }

    // MARK: - Nombre visible

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
