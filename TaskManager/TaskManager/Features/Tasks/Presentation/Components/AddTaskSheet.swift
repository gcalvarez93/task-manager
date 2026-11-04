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
    @State private var isSaving = false
    @State private var errorMessage: String?

    private var isEditing: Bool { taskToEdit != nil }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

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
                        Task { await save() }
                    }
                    .disabled(trimmedTitle.isEmpty || isSaving)
                }
            }
            .alert(String(localized: "error"), isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button(String(localized: "OK"), role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
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

    /// Guarda y cierra la hoja solo si salió bien. Si falla, la hoja sigue abierta con lo escrito
    /// y se avisa con una alerta.
    private func save() async {
        isSaving = true
        defer { isSaving = false }

        let message: String?
        if isEditing, let task = taskToEdit {
            message = await viewModel.editTask(
                id: task.id,
                title: title,
                description: description,
                priority: priority,
                status: status,
                dueDate: hasDueDate ? dueDate : nil,
                labels: task.labels
            )
        } else {
            message = await viewModel.addTask(
                title: title,
                description: description,
                priority: priority,
                status: status,
                dueDate: hasDueDate ? dueDate : nil,
                labels: []
            )
        }

        if let message {
            errorMessage = message
        } else {
            dismiss()
        }
    }
}
