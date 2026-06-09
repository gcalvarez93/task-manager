//
//  BoardsViewModel.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Boards/Presentation/ViewModels/BoardsViewModel.swift
import Foundation
import Observation

enum BoardsState: Equatable {
    case initial
    case loading
    case loaded([BoardEntity])
    case error(String)
}

@Observable
final class BoardsViewModel {
    var state: BoardsState = .initial
    var showAddBoard = false
    var boardToEdit: BoardEntity? = nil

    private let getBoards: GetBoardsUseCase
    private let createBoard: CreateBoardUseCase
    private let updateBoard: UpdateBoardUseCase
    private let deleteBoard: DeleteBoardUseCase

    init(
        getBoards: GetBoardsUseCase = GetBoardsUseCase(repository: BoardRepository()),
        createBoard: CreateBoardUseCase = CreateBoardUseCase(repository: BoardRepository()),
        updateBoard: UpdateBoardUseCase = UpdateBoardUseCase(repository: BoardRepository()),
        deleteBoard: DeleteBoardUseCase = DeleteBoardUseCase(repository: BoardRepository())
    ) {
        self.getBoards = getBoards
        self.createBoard = createBoard
        self.updateBoard = updateBoard
        self.deleteBoard = deleteBoard
    }

    func loadBoards() async {
        state = .loading
        do {
            let boards = try await getBoards.execute()
            state = .loaded(boards)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func addBoard(name: String, description: String, color: String) async {
        do {
            _ = try await createBoard.execute(name: name, description: description, color: color)
            await loadBoards()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func editBoard(id: String, name: String, description: String, color: String) async {
        do {
            _ = try await updateBoard.execute(id: id, name: name, description: description, color: color)
            await loadBoards()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func removeBoard(id: String) async {
        do {
            try await deleteBoard.execute(id: id)
            await loadBoards()
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
