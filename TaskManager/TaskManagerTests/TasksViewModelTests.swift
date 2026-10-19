// Path: TaskManager/TaskManagerTests/TasksViewModelTests.swift
import Foundation
import Testing
@testable import TaskManager

@MainActor
struct TasksViewModelTests {
    private let repository = FakeTaskRepository()

    private func makeViewModel() -> TasksViewModel {
        TasksViewModel(
            board: TestData.board,
            getTasks: GetTasksUseCase(repository: repository),
            createTask: CreateTaskUseCase(repository: repository),
            updateTask: UpdateTaskUseCase(repository: repository),
            deleteTask: DeleteTaskUseCase(repository: repository)
        )
    }

    private func task(id: String, status: TaskStatus) -> TaskEntity {
        TaskEntity(
            id: id,
            boardId: "b1",
            title: "Tarea \(id)",
            description: "",
            priority: .medium,
            status: status,
            dueDate: nil,
            labels: [],
            createdAt: TestData.referenceDate
        )
    }

    @Test func loadTasksExposesTheLoadedTasks() async {
        repository.tasksResult = .success([TestData.task])
        let viewModel = makeViewModel()

        await viewModel.loadTasks()

        #expect(viewModel.state == .loaded([TestData.task]))
    }

    @Test func loadTasksFailureShowsTheMessage() async {
        repository.tasksResult = .failure(.server("boom"))
        let viewModel = makeViewModel()

        await viewModel.loadTasks()

        #expect(viewModel.state == .error("boom"))
    }

    @Test func addTaskReloadsTheList() async {
        let viewModel = makeViewModel()

        await viewModel.addTask(
            title: "Nueva",
            description: "",
            priority: .low,
            status: .todo,
            dueDate: nil,
            labels: []
        )

        #expect(repository.getTasksCalls == 1)
        #expect(viewModel.state == .loaded([]))
    }

    @Test func addTaskFailureShowsTheMessageAndDoesNotReload() async {
        repository.createResult = .failure(.network("offline"))
        let viewModel = makeViewModel()

        await viewModel.addTask(
            title: "Nueva",
            description: "",
            priority: .low,
            status: .todo,
            dueDate: nil,
            labels: []
        )

        #expect(viewModel.state == .error("offline"))
        #expect(repository.getTasksCalls == 0)
    }

    @Test func editTaskReloadsTheList() async {
        let viewModel = makeViewModel()

        await viewModel.editTask(
            id: "t1",
            title: "Editada",
            description: "",
            priority: .high,
            status: .done,
            dueDate: nil,
            labels: []
        )

        #expect(repository.updatedId == "t1")
        #expect(repository.getTasksCalls == 1)
    }

    @Test func removeTaskDeletesAndReloads() async {
        let viewModel = makeViewModel()

        await viewModel.removeTask(id: "t1")

        #expect(repository.deletedId == "t1")
        #expect(repository.getTasksCalls == 1)
    }

    @Test func removeTaskFailureShowsTheMessage() async {
        repository.deleteResult = .failure(.server("not found"))
        let viewModel = makeViewModel()

        await viewModel.removeTask(id: "t1")

        #expect(viewModel.state == .error("not found"))
    }

    @Test func tasksByStatusFiltersTheLoadedTasks() async {
        repository.tasksResult = .success([
            task(id: "1", status: .todo),
            task(id: "2", status: .done),
            task(id: "3", status: .todo)
        ])
        let viewModel = makeViewModel()
        await viewModel.loadTasks()

        #expect(viewModel.tasksByStatus(.todo).map(\.id) == ["1", "3"])
        #expect(viewModel.tasksByStatus(.done).map(\.id) == ["2"])
        #expect(viewModel.tasksByStatus(.inProgress).isEmpty)
    }

    @Test func tasksByStatusIsEmptyBeforeLoading() {
        #expect(makeViewModel().tasksByStatus(.todo).isEmpty)
    }
}
