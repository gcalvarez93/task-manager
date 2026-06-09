//
//  BoardsView.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Boards/Presentation/Views/BoardsView.swift
import SwiftUI

struct BoardsView: View {
    @State private var viewModel = BoardsViewModel()
    @Environment(AuthViewModel.self) private var authViewModel

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .initial, .loading:
                    ProgressView()
                case .loaded(let boards):
                    if boards.isEmpty {
                        emptyState
                    } else {
                        boardsGrid(boards)
                    }
                case .error(let message):
                    ContentUnavailableView(
                        String(localized: "error"),
                        systemImage: "exclamationmark.triangle",
                        description: Text(message)
                    )
                }
            }
            .navigationTitle(String(localized: "nav_boards"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.showAddBoard = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel.showAddBoard },
                set: { viewModel.showAddBoard = $0 }
            )) {
                AddBoardSheet()
                    .environment(viewModel)
            }
            .sheet(item: Binding(
                get: { viewModel.boardToEdit },
                set: { viewModel.boardToEdit = $0 }
            )) { board in
                AddBoardSheet(boardToEdit: board)
                    .environment(viewModel)
            }
            .task {
                await viewModel.loadBoards()
            }
            .refreshable {
                await viewModel.loadBoards()
            }
        }
        .environment(viewModel)
    }

    private var emptyState: some View {
        ContentUnavailableView(
            String(localized: "no_boards"),
            systemImage: "square.grid.2x2",
            description: Text(String(localized: "no_boards_description"))
        )
    }

    private func boardsGrid(_ boards: [BoardEntity]) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(boards) { board in
                    NavigationLink {
                        TasksView(board: board)
                    } label: {
                        BoardCardView(board: board)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button {
                            viewModel.boardToEdit = board
                        } label: {
                            Label(String(localized: "edit"), systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            Task { await viewModel.removeBoard(id: board.id) }
                        } label: {
                            Label(String(localized: "delete"), systemImage: "trash")
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
    }
}
