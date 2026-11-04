//
//  LoginView.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Auth/Presentation/Views/LoginView.swift
import SwiftUI

struct LoginView: View {
    @Environment(AuthViewModel.self) private var viewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var showError = false
    @State private var errorMessage = ""

    private var isBusy: Bool {
        if case .loading = viewModel.state { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 40)

                    // Logo
                    Image(systemName: "checkmark.square.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue)

                    Text(String(localized: "app_name"))
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(String(localized: "login_subtitle"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer().frame(height: 16)

                    // Fields
                    VStack(spacing: 16) {
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

                    // Login button
                    Button {
                        Task { await viewModel.signInWithEmail(email: email, password: password) }
                    } label: {
                        Group {
                            if isBusy {
                                ProgressView().tint(.white)
                            } else {
                                Text(String(localized: "sign_in"))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .cornerRadius(12)
                    }
                    .disabled(email.isEmpty || password.isEmpty || isBusy)

                    // Divider
                    HStack {
                        Rectangle().frame(height: 1).foregroundStyle(Color(.systemGray4))
                        Text("o").foregroundStyle(.secondary).padding(.horizontal, 8)
                        Rectangle().frame(height: 1).foregroundStyle(Color(.systemGray4))
                    }

                    // Google
                    GoogleSignInButton {
                        Task { await viewModel.signInWithGoogle() }
                    }
                    .disabled(isBusy)

                    // Register
                    HStack {
                        Text(String(localized: "no_account"))
                            .foregroundStyle(.secondary)
                        Button(String(localized: "register")) {
                            showRegister = true
                        }
                    }
                    .font(.subheadline)
                }
                .padding(.horizontal, 24)
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
            .onChange(of: viewModel.state) { _, newState in
                // Con el registro abierto, es esa pantalla la que avisa; si no, saldrían dos alertas.
                if case .error(let message) = newState, !showRegister {
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
}
