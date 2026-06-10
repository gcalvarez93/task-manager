//
//  TasksView.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Tasks/Presentation/Views/TasksView.swift
import SwiftUI

struct TasksView: View {
    let board: BoardEntity
    @State private var viewModel: TasksViewModel

    init(board: BoardEntity) {
        self.board = board
        self._viewModel = State(initialValue: TasksViewModel(board: board))
    }

    private var boardColor: Color {
        Color(hex: board.color) ?? .blue
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .initial, .loading:
                ProgressView()
            case .loaded(let tasks):
                if tasks.isEmpty {
                    emptyState
                } else {
                    tasksList(tasks)
                }
            case .error(let message):
                ContentUnavailableView(
                    String(localized: "error"),
                    systemImage: "exclamationmark.triangle",
                    description: Text(message)
                )
            }
        }
        .navigationTitle(board.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.showAddTask = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel.showAddTask },
            set: { viewModel.showAddTask = $0 }
        )) {
            AddTaskSheet()
                .environment(viewModel)
        }
        .sheet(item: Binding(
            get: { viewModel.taskToEdit },
            set: { viewModel.taskToEdit = $0 }
        )) { task in
            AddTaskSheet(taskToEdit: task)
                .environment(viewModel)
        }
        .task {
            await viewModel.loadTasks()
        }
        .refreshable {
            await viewModel.loadTasks()
        }
        .environment(viewModel)
    }

    private var emptyState: some View {
        ContentUnavailableView(
            String(localized: "no_tasks"),
            systemImage: "checkmark.square",
            description: Text(String(localized: "no_tasks_description"))
        )
    }

    private func tasksList(_ tasks: [TaskEntity]) -> some View {
        List {
            ForEach(TaskStatus.allCases, id: \.self) { status in
                let filtered = viewModel.tasksByStatus(status)
                if !filtered.isEmpty {
                    Section {
                        ForEach(filtered) { task in
                            TaskRowView(task: task)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .contextMenu {
                                    Button {
                                        viewModel.taskToEdit = task
                                    } label: {
                                        Label(String(localized: "edit"), systemImage: "pencil")
                                    }
                                    Button(role: .destructive) {
                                        Task { await viewModel.removeTask(id: task.id) }
                                    } label: {
                                        Label(String(localized: "delete"), systemImage: "trash")
                                    }
                                }
                        }
                    } header: {
                        TaskStatusBadge(status: status)
                            .textCase(nil)
                    }
                }
            }
        }
        .listStyle(.plain)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    NavigationStack {
        TasksView(board: BoardEntity(
            id: "1",
            name: "My Project",
            description: "A sample project board",
            color: "#3B82F6",
            taskCount: 3,
            createdAt: Date()
        ))
    }
}
