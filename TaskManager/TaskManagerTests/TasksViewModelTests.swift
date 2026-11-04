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

    /// Un ViewModel que ya tiene una tarea cargada, para comprobar que un fallo no la pierde.
    private func makeLoadedViewModel() async -> TasksViewModel {
        repository.tasksResult = .success([TestData.task])
        let viewModel = makeViewModel()
        await viewModel.loadTasks()
        return viewModel
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

    private func add(_ viewModel: TasksViewModel, title: String = "Nueva") async -> String? {
        await viewModel.addTask(
            title: title,
            description: "",
            priority: .low,
            status: .todo,
            dueDate: nil,
            labels: []
        )
    }

    private func edit(_ viewModel: TasksViewModel, title: String = "Editada") async -> String? {
        await viewModel.editTask(
            id: "t1",
            title: title,
            description: "",
            priority: .high,
            status: .done,
            dueDate: nil,
            labels: []
        )
    }

    // MARK: - Carga

    @Test func loadTasksExposesTheLoadedTasks() async {
        repository.tasksResult = .success([TestData.task])
        let viewModel = makeViewModel()

        await viewModel.loadTasks()

        #expect(viewModel.state == .loaded([TestData.task]))
    }

    @Test func loadTasksFailureShowsTheUserMessage() async {
        repository.tasksResult = .failure(.server("HTTP 500"))
        let viewModel = makeViewModel()

        await viewModel.loadTasks()

        #expect(viewModel.state == .error(Failure.server("HTTP 500").userMessage))
    }

    @Test func loadTasksFailureDoesNotExposeTheTechnicalDetail() async {
        repository.tasksResult = .failure(.server("HTTP 500"))
        let viewModel = makeViewModel()

        await viewModel.loadTasks()

        guard case .error(let message) = viewModel.state else {
            Issue.record("Expected an error state")
            return
        }
        #expect(!message.contains("HTTP 500"))
    }

    @Test func aCancelledLoadDoesNotShowAnError() async {
        repository.tasksError = CancellationError()
        let viewModel = makeViewModel()

        await viewModel.loadTasks()

        #expect(viewModel.state == .initial)
    }

    @Test func aCancelledReloadKeepsTheLoadedTasks() async {
        let viewModel = await makeLoadedViewModel()
        repository.tasksError = CancellationError()

        await viewModel.loadTasks()

        #expect(viewModel.state == .loaded([TestData.task]))
    }

    // MARK: - Crear

    @Test func addTaskReloadsTheListAndReturnsNil() async {
        let viewModel = makeViewModel()

        let message = await add(viewModel)

        #expect(message == nil)
        #expect(repository.getTasksCalls == 1)
        #expect(viewModel.state == .loaded([]))
    }

    @Test func failedAddTaskReturnsTheUserMessageAndKeepsTheList() async {
        let viewModel = await makeLoadedViewModel()
        repository.createResult = .failure(.network("offline"))

        let message = await add(viewModel)

        #expect(message == Failure.network("offline").userMessage)
        #expect(viewModel.state == .loaded([TestData.task]))
        #expect(repository.getTasksCalls == 1)
    }

    @Test func addTaskWithABlankTitleReturnsTheValidationMessageAndKeepsTheList() async {
        let viewModel = await makeLoadedViewModel()

        let message = await add(viewModel, title: "   ")

        #expect(message == String(localized: "validation_title_empty"))
        #expect(repository.createCalls == 0)
        #expect(viewModel.state == .loaded([TestData.task]))
    }

    @Test func addTaskSendsTheTitleWithoutSurroundingSpaces() async {
        let viewModel = makeViewModel()

        _ = await add(viewModel, title: "  Nueva ")

        #expect(repository.lastCreatedTitle == "Nueva")
    }

    // MARK: - Editar

    @Test func editTaskReloadsTheListAndReturnsNil() async {
        let viewModel = makeViewModel()

        let message = await edit(viewModel)

        #expect(message == nil)
        #expect(repository.updatedId == "t1")
        #expect(repository.getTasksCalls == 1)
    }

    @Test func failedEditTaskReturnsTheUserMessageAndKeepsTheList() async {
        let viewModel = await makeLoadedViewModel()
        repository.updateResult = .failure(.network("offline"))

        let message = await edit(viewModel)

        #expect(message == Failure.network("offline").userMessage)
        #expect(viewModel.state == .loaded([TestData.task]))
    }

    @Test func editTaskWithABlankTitleReturnsTheValidationMessage() async {
        let viewModel = makeViewModel()

        let message = await edit(viewModel, title: " ")

        #expect(message == String(localized: "validation_title_empty"))
        #expect(repository.updateCalls == 0)
    }

    // MARK: - Borrar

    @Test func removeTaskDeletesAndReloads() async {
        let viewModel = makeViewModel()

        let message = await viewModel.removeTask(id: "t1")

        #expect(message == nil)
        #expect(repository.deletedId == "t1")
        #expect(repository.getTasksCalls == 1)
    }

    @Test func failedRemoveTaskReturnsTheUserMessageAndKeepsTheList() async {
        let viewModel = await makeLoadedViewModel()
        repository.deleteResult = .failure(.server("HTTP 404"))

        let message = await viewModel.removeTask(id: "t1")

        #expect(message == Failure.server("HTTP 404").userMessage)
        #expect(viewModel.state == .loaded([TestData.task]))
        #expect(repository.getTasksCalls == 1)
    }

    // MARK: - Filtrado

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
