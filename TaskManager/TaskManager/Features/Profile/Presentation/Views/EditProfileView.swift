//
//  EditProfileView.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Profile/Presentation/Views/EditProfileView.swift
import SwiftUI
import FirebaseAuth

struct EditProfileView: View {
    @Environment(ProfileViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var isLoading = false

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
                        Task {
                            isLoading = true
                            if case .loaded(let profile) = viewModel.state {
                                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                changeRequest?.displayName = name
                                try? await changeRequest?.commitChanges()
                                await viewModel.update(
                                    name: name,
                                    language: profile.language,
                                    notifications: profile.notifications
                                )
                            }
                            isLoading = false
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty || isLoading)
                }
            }
            .onAppear {
                if case .loaded(let profile) = viewModel.state {
                    name = profile.name
                }
            }
        }
    }
}
