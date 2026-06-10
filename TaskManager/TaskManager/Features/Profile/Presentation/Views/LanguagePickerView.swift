//
//  LanguagePickerView.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Profile/Presentation/Views/LanguagePickerView.swift
import SwiftUI

struct LanguagePickerView: View {
    @Environment(ProfileViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    private let languages: [(code: String, name: String, flag: String)] = [
        ("es", "Español", "🇪🇸"),
        ("en", "English", "🇬🇧")
    ]

    var body: some View {
        NavigationStack {
            List(languages, id: \.code) { language in
                Button {
                    Task {
                        if case .loaded(let profile) = viewModel.state {
                            await viewModel.update(
                                name: profile.name,
                                language: language.code,
                                notifications: profile.notifications
                            )
                        }
                        dismiss()
                    }
                } label: {
                    HStack {
                        Text(language.flag)
                            .font(.title2)
                        Text(language.name)
                            .foregroundStyle(.primary)
                        Spacer()
                        if case .loaded(let profile) = viewModel.state,
                           profile.language == language.code {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "language"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel")) { dismiss() }
                }
            }
        }
    }
}
