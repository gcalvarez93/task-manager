//
//  AuthViewModel.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Auth/Presentation/ViewModels/AuthViewModel.swift
import Foundation
import Observation

enum AuthState: Equatable {
    case initial
    case loading
    case authenticated(UserEntity)
    case unauthenticated
    case error(String)
}

@Observable
final class AuthViewModel {
    var state: AuthState = .initial

    private let loginWithEmail: LoginWithEmailUseCase
    private let registerWithEmail: RegisterWithEmailUseCase
    private let loginWithGoogle: LoginWithGoogleUseCase
    private let logout: LogoutUseCase
    private let repository: AuthRepositoryProtocol

    init(
        loginWithEmail: LoginWithEmailUseCase = LoginWithEmailUseCase(repository: AuthRepository()),
        registerWithEmail: RegisterWithEmailUseCase = RegisterWithEmailUseCase(repository: AuthRepository()),
        loginWithGoogle: LoginWithGoogleUseCase = LoginWithGoogleUseCase(repository: AuthRepository()),
        logout: LogoutUseCase = LogoutUseCase(repository: AuthRepository()),
        repository: AuthRepositoryProtocol = AuthRepository()
    ) {
        self.loginWithEmail = loginWithEmail
        self.registerWithEmail = registerWithEmail
        self.loginWithGoogle = loginWithGoogle
        self.logout = logout
        self.repository = repository
        checkCurrentUser()
    }

    func checkCurrentUser() {
        if let user = repository.getCurrentUser() {
            state = .authenticated(user)
        } else {
            state = .unauthenticated
        }
    }

    func signInWithEmail(email: String, password: String) async {
        state = .loading
        do {
            let user = try await loginWithEmail.execute(email: email, password: password)
            state = .authenticated(user)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func signUpWithEmail(email: String, password: String, name: String) async {
        state = .loading
        do {
            let user = try await registerWithEmail.execute(email: email, password: password, name: name)
            state = .authenticated(user)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func signInWithGoogle() async {
        state = .loading
        do {
            let user = try await loginWithGoogle.execute()
            state = .authenticated(user)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func signOut() async {
        state = .loading
        do {
            try await logout.execute()
            state = .unauthenticated
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
