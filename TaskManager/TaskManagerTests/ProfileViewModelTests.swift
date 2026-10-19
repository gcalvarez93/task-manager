// Path: TaskManager/TaskManagerTests/ProfileViewModelTests.swift
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

    @Test func loadProfileFailureShowsTheMessage() async {
        repository.profileResult = .failure(.server("boom"))
        let viewModel = makeViewModel()

        await viewModel.loadProfile()

        #expect(viewModel.state == .error("boom"))
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
        repository.updateResult = .failure(.server("boom"))

        let saved = await viewModel.update(name: "Nuevo nombre", language: "en", notifications: false)

        #expect(!saved)
        #expect(viewModel.state == .loaded(TestData.profile))
    }
}
