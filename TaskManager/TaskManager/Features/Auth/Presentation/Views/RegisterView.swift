//
//  RegisterView.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Auth/Presentation/Views/RegisterView.swift
import SwiftUI

struct RegisterView: View {
    @Environment(AuthViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 24)

                VStack(spacing: 16) {
                    AuthTextField(
                        title: String(localized: "name"),
                        text: $name
                    )
                    AuthTextField(
                        title: String(localized: "email"),
                        text: $email,
                        keyboardType: .emailAddress
                    )
                    AuthTextField(
                        title: String(localized: "password"),
                        text: $password,
                        isSecure: true
                    )
                }

                Button {
                    Task {
                        await viewModel.signUpWithEmail(
                            email: email,
                            password: password,
                            name: name
                        )
                    }
                } label: {
                    Group {
                        if case .loading = viewModel.state {
                            ProgressView().tint(.white)
                        } else {
                            Text(String(localized: "register"))
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .cornerRadius(12)
                }
                .disabled(name.isEmpty || email.isEmpty || password.isEmpty)

                HStack {
                    Rectangle().frame(height: 1).foregroundStyle(Color(.systemGray4))
                    Text("o").foregroundStyle(.secondary).padding(.horizontal, 8)
                    Rectangle().frame(height: 1).foregroundStyle(Color(.systemGray4))
                }

                GoogleSignInButton {
                    Task { await viewModel.signInWithGoogle() }
                }
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle(String(localized: "create_account"))
        .navigationBarTitleDisplayMode(.large)
        .onChange(of: viewModel.state) { _, newState in
            if case .authenticated = newState {
                dismiss()
            }
            if case .error(let message) = newState {
                errorMessage = message
                showError = true
            }
        }
        .alert(String(localized: "error"), isPresented: $showError) {
            Button("OK") { showError = false }
        } message: {
            Text(errorMessage)
        }
    }
}
