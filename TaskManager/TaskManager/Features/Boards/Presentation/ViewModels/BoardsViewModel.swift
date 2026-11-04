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
        let previous = state
        state = .loading
        do {
            let boards = try await getBoards.execute()
            state = .loaded(boards)
        } catch {
            if error.isCancellation {
                restoreAfterCancellation(previous)
                return
            }
            AppLogger.error("BoardsViewModel.loadBoards", error)
            state = .error(error.userFacingMessage)
        }
    }

    // Las operaciones de escritura devuelven `nil` si salieron bien o el mensaje para el usuario
    // si fallaron. Un fallo no sustituye la lista ya cargada: la pantalla decide cómo avisar.

    @discardableResult
    func addBoard(name: String, description: String, color: String) async -> String? {
        do {
            _ = try await createBoard.execute(name: name, description: description, color: color)
        } catch {
            return failureMessage(for: error, context: "BoardsViewModel.addBoard")
        }
        await loadBoards()
        return nil
    }

    @discardableResult
    func editBoard(id: String, name: String, description: String, color: String) async -> String? {
        do {
            _ = try await updateBoard.execute(id: id, name: name, description: description, color: color)
        } catch {
            return failureMessage(for: error, context: "BoardsViewModel.editBoard")
        }
        await loadBoards()
        return nil
    }

    @discardableResult
    func removeBoard(id: String) async -> String? {
        do {
            try await deleteBoard.execute(id: id)
        } catch {
            return failureMessage(for: error, context: "BoardsViewModel.removeBoard")
        }
        await loadBoards()
        return nil
    }

    /// Registra el fallo y devuelve el mensaje para el usuario. Una cancelación no es un fallo: `nil`.
    private func failureMessage(for error: Error, context: String) -> String? {
        if error.isCancellation { return nil }
        AppLogger.error(context, error)
        return error.userFacingMessage
    }

    private func restoreAfterCancellation(_ previous: BoardsState) {
        if case .loading = previous {
            state = .initial
        } else {
            state = previous
        }
    }
}
