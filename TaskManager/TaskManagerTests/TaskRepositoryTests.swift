// Path: TaskManager/TaskManagerTests/TaskRepositoryTests.swift
import Testing
@testable import TaskManager

@MainActor
struct TaskRepositoryTests {
    private let dataSource = FakeTaskRemoteDataSource()

    private func makeRepository() -> TaskRepository {
        TaskRepository(dataSource: dataSource)
    }

    @Test func getTasksMapsModelsToEntities() async throws {
        dataSource.tasks = [
            TaskModel(
                id: "t1",
                boardId: "b1",
                title: "Preparar demo",
                description: "Revisar el flujo completo",
                priority: "high",
                status: "inProgress",
                dueDate: nil,
                labels: ["demo"],
                createdAt: TestData.referenceDate
            )
        ]

        let tasks = try await makeRepository().getTasks(boardId: "b1")

        #expect(tasks.count == 1)
        #expect(tasks[0].priority == .high)
        #expect(tasks[0].status == .inProgress)
        #expect(tasks[0].labels == ["demo"])
    }

    @Test func unknownPriorityAndStatusFallBackToDefaults() async throws {
        dataSource.tasks = [
            TaskModel(
                id: "t1",
                boardId: "b1",
                title: "Rara",
                description: "",
                priority: "urgent",
                status: "archived",
                dueDate: nil,
                labels: [],
                createdAt: TestData.referenceDate
            )
        ]

        let tasks = try await makeRepository().getTasks(boardId: "b1")

        #expect(tasks[0].priority == .medium)
        #expect(tasks[0].status == .todo)
    }

    @Test func createTaskSendsTheRawValuesToTheApi() async throws {
        _ = try await makeRepository().createTask(
            boardId: "b1",
            title: "Nueva",
            description: "Detalle",
            priority: .low,
            status: .inProgress,
            dueDate: nil,
            labels: ["a", "b"]
        )

        let request = try #require(dataSource.lastCreateRequest)
        #expect(request.boardId == "b1")
        #expect(request.priority == "low")
        #expect(request.status == "inProgress")
        #expect(request.labels == ["a", "b"])
    }

    @Test func updateTaskSendsTheRawValuesToTheApi() async throws {
        _ = try await makeRepository().updateTask(
            id: "t1",
            title: "Editada",
            description: "",
            priority: .high,
            status: .done,
            dueDate: nil,
            labels: []
        )

        let request = try #require(dataSource.lastUpdateRequest)
        #expect(request.priority == "high")
        #expect(request.status == "done")
    }

    @Test func dataSourceErrorsPropagate() async {
        dataSource.error = .server("boom")

        await #expect(throws: Failure.server("boom")) {
            _ = try await makeRepository().getTasks(boardId: "b1")
        }
    }
}
