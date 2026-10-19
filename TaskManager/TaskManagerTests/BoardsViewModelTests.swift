// Path: TaskManager/TaskManagerTests/BoardsViewModelTests.swift
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

    @Test func loadBoardsExposesTheLoadedBoards() async {
        repository.boardsResult = .success([TestData.board])
        let viewModel = makeViewModel()

        await viewModel.loadBoards()

        #expect(viewModel.state == .loaded([TestData.board]))
    }

    @Test func loadBoardsFailureShowsTheMessage() async {
        repository.boardsResult = .failure(.server("boom"))
        let viewModel = makeViewModel()

        await viewModel.loadBoards()

        #expect(viewModel.state == .error("boom"))
    }

    @Test func addBoardReloadsTheList() async {
        let viewModel = makeViewModel()

        await viewModel.addBoard(name: "Casa", description: "", color: "#FF0000")

        #expect(repository.getBoardsCalls == 1)
    }

    @Test func addBoardFailureShowsTheMessageAndDoesNotReload() async {
        repository.createResult = .failure(.network("offline"))
        let viewModel = makeViewModel()

        await viewModel.addBoard(name: "Casa", description: "", color: "#FF0000")

        #expect(viewModel.state == .error("offline"))
        #expect(repository.getBoardsCalls == 0)
    }

    @Test func removeBoardDeletesAndReloads() async {
        let viewModel = makeViewModel()

        await viewModel.removeBoard(id: "b1")

        #expect(repository.deletedId == "b1")
        #expect(repository.getBoardsCalls == 1)
    }
}
