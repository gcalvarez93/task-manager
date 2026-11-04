// Path: TaskManager/TaskManagerTests/BoardsViewModelTests.swift
import Foundation
import Testing
@testable import TaskManager

@MainActor
struct BoardsViewModelTests {
    private let repository = FakeBoardRepository()

    private func makeViewModel() -> BoardsViewModel {
        BoardsViewModel(
            getBoards: GetBoardsUseCase(repository: repository),
            createBoard: CreateBoardUseCase(repository: repository),
            updateBoard: UpdateBoardUseCase(repository: repository),
            deleteBoard: DeleteBoardUseCase(repository: repository)
        )
    }

    /// Un ViewModel que ya tiene un tablero cargado, para comprobar que un fallo no lo pierde.
    private func makeLoadedViewModel() async -> BoardsViewModel {
        repository.boardsResult = .success([TestData.board])
        let viewModel = makeViewModel()
        await viewModel.loadBoards()
        return viewModel
    }

    // MARK: - Carga

    @Test func loadBoardsExposesTheLoadedBoards() async {
        repository.boardsResult = .success([TestData.board])
        let viewModel = makeViewModel()

        await viewModel.loadBoards()

        #expect(viewModel.state == .loaded([TestData.board]))
    }

    @Test func loadBoardsFailureShowsTheUserMessage() async {
        repository.boardsResult = .failure(.server("HTTP 500"))
        let viewModel = makeViewModel()

        await viewModel.loadBoards()

        #expect(viewModel.state == .error(Failure.server("HTTP 500").userMessage))
    }

    @Test func loadBoardsFailureDoesNotExposeTheTechnicalDetail() async {
        repository.boardsResult = .failure(.server("HTTP 500"))
        let viewModel = makeViewModel()

        await viewModel.loadBoards()

        guard case .error(let message) = viewModel.state else {
            Issue.record("Expected an error state")
            return
        }
        #expect(!message.contains("HTTP 500"))
    }

    @Test func aCancelledLoadDoesNotShowAnError() async {
        repository.boardsError = CancellationError()
        let viewModel = makeViewModel()

        await viewModel.loadBoards()

        #expect(viewModel.state == .initial)
    }

    @Test func aCancelledReloadKeepsTheLoadedBoards() async {
        let viewModel = await makeLoadedViewModel()
        repository.boardsError = CancellationError()

        await viewModel.loadBoards()

        #expect(viewModel.state == .loaded([TestData.board]))
    }

    // MARK: - Crear

    @Test func addBoardReloadsTheListAndReturnsNil() async {
        let viewModel = makeViewModel()

        let message = await viewModel.addBoard(name: "Casa", description: "", color: "#FF0000")

        #expect(message == nil)
        #expect(repository.getBoardsCalls == 1)
    }

    @Test func failedAddBoardReturnsTheUserMessageAndKeepsTheList() async {
        let viewModel = await makeLoadedViewModel()
        repository.createResult = .failure(.network("offline"))

        let message = await viewModel.addBoard(name: "Casa", description: "", color: "#FF0000")

        #expect(message == Failure.network("offline").userMessage)
        #expect(viewModel.state == .loaded([TestData.board]))
        #expect(repository.getBoardsCalls == 1)
    }

    @Test func addBoardWithABlankNameReturnsTheValidationMessageAndKeepsTheList() async {
        let viewModel = await makeLoadedViewModel()

        let message = await viewModel.addBoard(name: "   ", description: "", color: "#FF0000")

        #expect(message == String(localized: "validation_name_empty"))
        #expect(repository.createCalls == 0)
        #expect(viewModel.state == .loaded([TestData.board]))
    }

    @Test func addBoardSendsTheNameWithoutSurroundingSpaces() async {
        let viewModel = makeViewModel()

        await viewModel.addBoard(name: "  Casa ", description: "", color: "#FF0000")

        #expect(repository.lastCreatedName == "Casa")
    }

    // MARK: - Editar

    @Test func editBoardReloadsTheListAndReturnsNil() async {
        let viewModel = makeViewModel()

        let message = await viewModel.editBoard(id: "b1", name: "Casa", description: "", color: "#FF0000")

        #expect(message == nil)
        #expect(repository.updateCalls == 1)
        #expect(repository.getBoardsCalls == 1)
    }

    @Test func failedEditBoardReturnsTheUserMessageAndKeepsTheList() async {
        let viewModel = await makeLoadedViewModel()
        repository.updateResult = .failure(.network("offline"))

        let message = await viewModel.editBoard(id: "b1", name: "Casa", description: "", color: "#FF0000")

        #expect(message == Failure.network("offline").userMessage)
        #expect(viewModel.state == .loaded([TestData.board]))
    }

    @Test func editBoardWithABlankNameReturnsTheValidationMessage() async {
        let viewModel = makeViewModel()

        let message = await viewModel.editBoard(id: "b1", name: " ", description: "", color: "#FF0000")

        #expect(message == String(localized: "validation_name_empty"))
        #expect(repository.updateCalls == 0)
    }

    // MARK: - Borrar

    @Test func removeBoardDeletesAndReloads() async {
        let viewModel = makeViewModel()

        let message = await viewModel.removeBoard(id: "b1")

        #expect(message == nil)
        #expect(repository.deletedId == "b1")
        #expect(repository.getBoardsCalls == 1)
    }

    @Test func failedRemoveBoardReturnsTheUserMessageAndKeepsTheList() async {
        let viewModel = await makeLoadedViewModel()
        repository.deleteResult = .failure(.server("HTTP 404"))

        let message = await viewModel.removeBoard(id: "b1")

        #expect(message == Failure.server("HTTP 404").userMessage)
        #expect(viewModel.state == .loaded([TestData.board]))
        #expect(repository.getBoardsCalls == 1)
    }

    @Test func aCancelledRemoveReturnsNilWithoutReloading() async {
        let viewModel = await makeLoadedViewModel()
        repository.deleteError = CancellationError()

        let message = await viewModel.removeBoard(id: "b1")

        #expect(message == nil)
        #expect(viewModel.state == .loaded([TestData.board]))
        #expect(repository.getBoardsCalls == 1)
    }
}
