//
//  AddBoardSheet.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Boards/Presentation/Components/AddBoardSheet.swift
import SwiftUI

struct AddBoardSheet: View {
    @Environment(BoardsViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    var boardToEdit: BoardEntity? = nil

    @State private var name = ""
    @State private var description = ""
    @State private var selectedColor = "#3B82F6"

    private let colors = [
        "#3B82F6", "#8B5CF6", "#10B981", "#F59E0B",
        "#EF4444", "#EC4899", "#06B6D4", "#84CC16"
    ]

    private var isEditing: Bool { boardToEdit != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "board_info")) {
                    TextField(String(localized: "board_name"), text: $name)
                    TextField(String(localized: "board_description"), text: $description)
                }

                Section(String(localized: "board_color")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color) ?? .blue)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                        .padding(2)
                                )
                                .onTapGesture { selectedColor = color }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(isEditing ? String(localized: "edit_board") : String(localized: "add_board"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "save")) {
                        Task {
                            if isEditing, let board = boardToEdit {
                                await viewModel.editBoard(
                                    id: board.id,
                                    name: name,
                                    description: description,
                                    color: selectedColor
                                )
                            } else {
                                await viewModel.addBoard(
                                    name: name,
                                    description: description,
                                    color: selectedColor
                                )
                            }
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                if let board = boardToEdit {
                    name = board.name
                    description = board.description
                    selectedColor = board.color
                }
            }
        }
    }
}
