//
//  ProfileView.swift
//  TaskManager
//
//  Created by Gabriel Castro on 10/06/2026.
//

// Path: TaskManager/Features/Profile/Presentation/Views/ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(ThemeManager.self) private var themeManager
    @State private var viewModel = ProfileViewModel()

    private var user: UserEntity? {
        if case .authenticated(let user) = authViewModel.state { return user }
        return nil
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .initial, .loading:
                    ProgressView()
                case .loaded(let profile):
                    profileContent(profile)
                case .error(let message):
                    ContentUnavailableView(
                        String(localized: "error"),
                        systemImage: "exclamationmark.triangle",
                        description: Text(message)
                    )
                }
            }
            .navigationTitle(String(localized: "nav_profile"))
            .task { await viewModel.loadProfile() }
        }
        .environment(viewModel)
    }

    @ViewBuilder
    private func profileContent(_ profile: ProfileEntity) -> some View {
        List {
            // Header
            Section {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 72, height: 72)
                        Text(profile.name.prefix(1).uppercased())
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text(profile.email)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }

            // Settings
            Section(String(localized: "settings")) {
                Button {
                    viewModel.showEditProfile = true
                } label: {
                    ProfileOptionRow(
                        icon: "person",
                        title: String(localized: "edit_profile"),
                        color: .blue
                    )
                }
                .foregroundStyle(.primary)

                // Idioma → abre ajustes del iPhone
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    ProfileOptionRow(
                        icon: "globe",
                        title: String(localized: "language"),
                        color: .green
                    )
                }
                .foregroundStyle(.primary)

                Toggle(isOn: Binding(
                    get: { profile.notifications },
                    set: { newValue in
                        Task {
                            await viewModel.update(
                                name: profile.name,
                                language: profile.language,
                                notifications: newValue
                            )
                        }
                    }
                )) {
                    ProfileOptionRow(
                        icon: "bell",
                        title: String(localized: "notifications"),
                        color: .orange
                    )
                }

                // Apariencia
                Picker(selection: Binding(
                    get: { themeManager.selectedTheme },
                    set: { themeManager.selectedTheme = $0 }
                )) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        Label(theme.label, systemImage: theme.icon).tag(theme)
                    }
                } label: {
                    ProfileOptionRow(
                        icon: "moon",
                        title: String(localized: "appearance"),
                        color: .purple
                    )
                }
            }

            // Account
            Section(String(localized: "account")) {
                Button(role: .destructive) {
                    Task { await authViewModel.signOut() }
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text(String(localized: "sign_out"))
                    }
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel.showEditProfile },
            set: { viewModel.showEditProfile = $0 }
        )) {
            EditProfileView()
                .environment(viewModel)
        }
    }
}

#Preview {
    ProfileView()
        .environment(AuthViewModel())
        .environment(ThemeManager())
}
