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
        state = .loading
        do {
            let tasks = try await getTasks.execute(boardId: board.id)
            state = .loaded(tasks)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func addTask(
        title: String,
        description: String,
        priority: TaskPriority,
        status: TaskStatus,
        dueDate: Date?,
        labels: [String]
    ) async {
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
            await loadTasks()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func editTask(
        id: String,
        title: String,
        description: String,
        priority: TaskPriority,
        status: TaskStatus,
        dueDate: Date?,
        labels: [String]
    ) async {
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
            await loadTasks()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func removeTask(id: String) async {
        do {
            try await deleteTask.execute(id: id)
            await loadTasks()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func tasksByStatus(_ status: TaskStatus) -> [TaskEntity] {
        guard case .loaded(let tasks) = state else { return [] }
        return tasks.filter { $0.status == status }
    }
}
