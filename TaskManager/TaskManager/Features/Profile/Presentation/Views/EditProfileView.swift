//
//  EditProfileView.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Profile/Presentation/Views/EditProfileView.swift
import SwiftUI

struct EditProfileView: View {
    @Environment(ProfileViewModel.self) private var viewModel
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var isSaving = false
    @State private var showError = false

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "profile_info")) {
                    TextField(String(localized: "name"), text: $name)
                }
            }
            .navigationTitle(String(localized: "edit_profile"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "save")) {
                        Task { await save() }
                    }
                    .disabled(trimmedName.isEmpty || isSaving)
                }
            }
            .alert(String(localized: "error"), isPresented: $showError) {
                Button(String(localized: "OK"), role: .cancel) {}
            } message: {
                Text(String(localized: "profile_update_error"))
            }
            .onAppear {
                if case .loaded(let profile) = viewModel.state {
                    name = profile.name
                }
            }
        }
    }

    /// Guarda primero en la API y después en Firebase. Los dos sistemas no se
    /// pueden actualizar de forma atómica: si Firebase falla, se restaura el
    /// nombre anterior en la API para no dejar dos nombres distintos.
    private func save() async {
        guard case .loaded(let profile) = viewModel.state else { return }
        isSaving = true
        defer { isSaving = false }

        let newName = trimmedName
        let savedInApi = await viewModel.update(
            name: newName,
            language: profile.language,
            notifications: profile.notifications
        )
        guard savedInApi else {
            showError = true
            return
        }

        if await authViewModel.updateDisplayName(newName) {
            dismiss()
            return
        }

        let restored = await viewModel.update(
            name: profile.name,
            language: profile.language,
            notifications: profile.notifications
        )
        if !restored {
            AppLogger.warning("EditProfileView.save: could not restore previous name in API")
        }
        showError = true
    }
}
