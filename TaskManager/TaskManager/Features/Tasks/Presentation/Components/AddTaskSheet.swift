//
//  AddTaskSheet.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Tasks/Presentation/Components/AddTaskSheet.swift
import SwiftUI

struct AddTaskSheet: View {
    @Environment(TasksViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    var taskToEdit: TaskEntity? = nil

    @State private var title = ""
    @State private var description = ""
    @State private var priority: TaskPriority = .medium
    @State private var status: TaskStatus = .todo
    @State private var dueDate: Date = Date()
    @State private var hasDueDate = false

    private var isEditing: Bool { taskToEdit != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "task_info")) {
                    TextField(String(localized: "task_title"), text: $title)
                    TextField(String(localized: "task_description"), text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section(String(localized: "task_priority")) {
                    Picker(String(localized: "task_priority"), selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { p in
                            Text(p.rawValue.capitalized).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(String(localized: "task_status")) {
                    Picker(String(localized: "task_status"), selection: $status) {
                        Text(String(localized: "status_todo")).tag(TaskStatus.todo)
                        Text(String(localized: "status_in_progress")).tag(TaskStatus.inProgress)
                        Text(String(localized: "status_done")).tag(TaskStatus.done)
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Toggle(String(localized: "task_due_date"), isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker(
                            String(localized: "task_due_date"),
                            selection: $dueDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                    }
                }
            }
            .navigationTitle(isEditing ? String(localized: "edit_task") : String(localized: "add_task"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "save")) {
                        Task {
                            if isEditing, let task = taskToEdit {
                                await viewModel.editTask(
                                    id: task.id,
                                    title: title,
                                    description: description,
                                    priority: priority,
                                    status: status,
                                    dueDate: hasDueDate ? dueDate : nil,
                                    labels: []
                                )
                            } else {
                                await viewModel.addTask(
                                    title: title,
                                    description: description,
                                    priority: priority,
                                    status: status,
                                    dueDate: hasDueDate ? dueDate : nil,
                                    labels: []
                                )
                            }
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                if let task = taskToEdit {
                    title = task.title
                    description = task.description
                    priority = task.priority
                    status = task.status
                    if let due = task.dueDate {
                        hasDueDate = true
                        dueDate = due
                    }
                }
            }
        }
    }
}
