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
    private let updateDisplayNameUseCase: UpdateDisplayNameUseCase
    private let repository: AuthRepositoryProtocol

    init(
        loginWithEmail: LoginWithEmailUseCase = LoginWithEmailUseCase(repository: AuthRepository()),
        registerWithEmail: RegisterWithEmailUseCase = RegisterWithEmailUseCase(repository: AuthRepository()),
        loginWithGoogle: LoginWithGoogleUseCase = LoginWithGoogleUseCase(repository: AuthRepository()),
        logout: LogoutUseCase = LogoutUseCase(repository: AuthRepository()),
        updateDisplayName: UpdateDisplayNameUseCase = UpdateDisplayNameUseCase(repository: AuthRepository()),
        repository: AuthRepositoryProtocol = AuthRepository()
    ) {
        self.loginWithEmail = loginWithEmail
        self.registerWithEmail = registerWithEmail
        self.loginWithGoogle = loginWithGoogle
        self.logout = logout
        self.updateDisplayNameUseCase = updateDisplayName
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
            AppLogger.error("AuthViewModel.signInWithEmail", error)
            state = .error(error.localizedDescription)
        }
    }

    func signUpWithEmail(email: String, password: String, name: String) async {
        state = .loading
        do {
            let user = try await registerWithEmail.execute(email: email, password: password, name: name)
            state = .authenticated(user)
        } catch {
            AppLogger.error("AuthViewModel.signUpWithEmail", error)
            state = .error(error.localizedDescription)
        }
    }

    func signInWithGoogle() async {
        state = .loading
        do {
            let user = try await loginWithGoogle.execute()
            state = .authenticated(user)
        } catch {
            AppLogger.error("AuthViewModel.signInWithGoogle", error)
            state = .error(error.localizedDescription)
        }
    }

    func signOut() async {
        state = .loading
        do {
            try await logout.execute()
            state = .unauthenticated
        } catch {
            AppLogger.error("AuthViewModel.signOut", error)
            state = .error(error.localizedDescription)
        }
    }

    /// Actualiza el nombre visible. Devuelve `true` si se guardó y, en ese
    /// caso, publica el usuario actualizado. Un fallo no altera el estado de
    /// autenticación, para no expulsar al usuario de la pantalla.
    func updateDisplayName(_ name: String) async -> Bool {
        do {
            let user = try await updateDisplayNameUseCase.execute(name: name)
            state = .authenticated(user)
            return true
        } catch {
            AppLogger.error("AuthViewModel.updateDisplayName", error)
            return false
        }
    }
}
