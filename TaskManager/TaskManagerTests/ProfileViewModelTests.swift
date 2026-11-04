// Path: TaskManager/TaskManagerTests/ProfileViewModelTests.swift
import Foundation
import Testing
@testable import TaskManager

@MainActor
struct ProfileViewModelTests {
    private let repository = FakeProfileRepository()

    private func makeViewModel() -> ProfileViewModel {
        ProfileViewModel(
            getProfile: GetProfileUseCase(repository: repository),
            updateProfile: UpdateProfileUseCase(repository: repository)
        )
    }

    @Test func loadProfileExposesTheProfile() async {
        let viewModel = makeViewModel()

        await viewModel.loadProfile()

        #expect(viewModel.state == .loaded(TestData.profile))
    }

    @Test func loadProfileFailureShowsTheUserMessage() async {
        repository.profileResult = .failure(.server("HTTP 500"))
        let viewModel = makeViewModel()

        await viewModel.loadProfile()

        #expect(viewModel.state == .error(Failure.server("HTTP 500").userMessage))
    }

    @Test func loadProfileFailureDoesNotExposeTheTechnicalDetail() async {
        repository.profileResult = .failure(.server("HTTP 500"))
        let viewModel = makeViewModel()

        await viewModel.loadProfile()

        guard case .error(let message) = viewModel.state else {
            Issue.record("Expected an error state")
            return
        }
        #expect(!message.contains("HTTP 500"))
    }

    @Test func aCancelledLoadDoesNotShowAnError() async {
        repository.profileError = CancellationError()
        let viewModel = makeViewModel()

        await viewModel.loadProfile()

        #expect(viewModel.state == .initial)
    }

    @Test func aCancelledReloadKeepsTheLoadedProfile() async {
        let viewModel = makeViewModel()
        await viewModel.loadProfile()
        repository.profileError = CancellationError()

        await viewModel.loadProfile()

        #expect(viewModel.state == .loaded(TestData.profile))
    }

    @Test func updateReturnsTrueAndPublishesTheSavedProfile() async {
        let viewModel = makeViewModel()
        await viewModel.loadProfile()

        let saved = await viewModel.update(name: "Nuevo nombre", language: "en", notifications: false)

        #expect(saved)
        guard case .loaded(let profile) = viewModel.state else {
            Issue.record("Expected a loaded state")
            return
        }
        #expect(profile.name == "Nuevo nombre")
        #expect(profile.language == "en")
        #expect(!profile.notifications)
    }

    @Test func failedUpdateReturnsFalseAndKeepsThePreviousProfile() async {
        let viewModel = makeViewModel()
        await viewModel.loadProfile()
        repository.updateResult = .failure(.server("HTTP 500"))

        let saved = await viewModel.update(name: "Nuevo nombre", language: "en", notifications: false)

        #expect(!saved)
        #expect(viewModel.state == .loaded(TestData.profile))
    }
}
