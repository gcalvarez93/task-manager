//
//  TasksViewModel.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Tasks/Presentation/ViewModels/TasksViewModel.swift
import Foundation
import Observation

enum TasksState: Equatable {
    case initial
    case loading
    case loaded([TaskEntity])
    case error(String)
}

@Observable
final class TasksViewModel {
    var state: TasksState = .initial
    var showAddTask = false
    var taskToEdit: TaskEntity? = nil

    private let board: BoardEntity
    private let getTasks: GetTasksUseCase
    private let createTask: CreateTaskUseCase
    private let updateTask: UpdateTaskUseCase
    private let deleteTask: DeleteTaskUseCase

    init(
        board: BoardEntity,
        getTasks: GetTasksUseCase = GetTasksUseCase(repository: TaskRepository()),
        createTask: CreateTaskUseCase = CreateTaskUseCase(repository: TaskRepository()),
        updateTask: UpdateTaskUseCase = UpdateTaskUseCase(repository: TaskRepository()),
        deleteTask: DeleteTaskUseCase = DeleteTaskUseCase(repository: TaskRepository())
    ) {
        self.board = board
        self.getTasks = getTasks
        self.createTask = createTask
        self.updateTask = updateTask
        self.deleteTask = deleteTask
    }

    var boardName: String { board.name }
    var boardColor: String { board.color }

    func loadTasks() async {
        let previous = state
        state = .loading
        do {
            let tasks = try await getTasks.execute(boardId: board.id)
            state = .loaded(tasks)
        } catch {
            if error.isCancellation {
                restoreAfterCancellation(previous)
                return
            }
            AppLogger.error("TasksViewModel.loadTasks", error)
            state = .error(error.userFacingMessage)
        }
    }

    // Las operaciones de escritura devuelven `nil` si salieron bien o el mensaje para el usuario
    // si fallaron. Un fallo no sustituye la lista ya cargada: la pantalla decide cómo avisar.

    @discardableResult
    func addTask(
        title: String,
        description: String,
        priority: TaskPriority,
        status: TaskStatus,
        dueDate: Date?,
        labels: [String]
    ) async -> String? {
        do {
            _ = try await createTask.execute(
                boardId: board.id,
                title: title,
                description: description,
                priority: priority,
                status: status,
                dueDate: dueDate,
                labels: labels
            )
        } catch {
            return failureMessage(for: error, context: "TasksViewModel.addTask")
        }
        await loadTasks()
        return nil
    }

    @discardableResult
    func editTask(
        id: String,
        title: String,
        description: String,
        priority: TaskPriority,
        status: TaskStatus,
        dueDate: Date?,
        labels: [String]
    ) async -> String? {
        do {
            _ = try await updateTask.execute(
                id: id,
                title: title,
                description: description,
                priority: priority,
                status: status,
                dueDate: dueDate,
                labels: labels
            )
        } catch {
            return failureMessage(for: error, context: "TasksViewModel.editTask")
        }
        await loadTasks()
        return nil
    }

    @discardableResult
    func removeTask(id: String) async -> String? {
        do {
            try await deleteTask.execute(id: id)
        } catch {
            return failureMessage(for: error, context: "TasksViewModel.removeTask")
        }
        await loadTasks()
        return nil
    }

    func tasksByStatus(_ status: TaskStatus) -> [TaskEntity] {
        guard case .loaded(let tasks) = state else { return [] }
        return tasks.filter { $0.status == status }
    }

    /// Registra el fallo y devuelve el mensaje para el usuario. Una cancelación no es un fallo: `nil`.
    private func failureMessage(for error: Error, context: String) -> String? {
        if error.isCancellation { return nil }
        AppLogger.error(context, error)
        return error.userFacingMessage
    }

    private func restoreAfterCancellation(_ previous: TasksState) {
        if case .loading = previous {
            state = .initial
        } else {
            state = previous
        }
    }
}
