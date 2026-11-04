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
            handleSignInFailure(error, context: "AuthViewModel.signInWithEmail")
        }
    }

    func signUpWithEmail(email: String, password: String, name: String) async {
        state = .loading
        do {
            let user = try await registerWithEmail.execute(email: email, password: password, name: name)
            state = .authenticated(user)
        } catch {
            handleSignInFailure(error, context: "AuthViewModel.signUpWithEmail")
        }
    }

    func signInWithGoogle() async {
        state = .loading
        do {
            let user = try await loginWithGoogle.execute()
            state = .authenticated(user)
        } catch {
            handleSignInFailure(error, context: "AuthViewModel.signInWithGoogle")
        }
    }

    /// Cierra la sesión. Devuelve `nil` si salió bien o el mensaje para el usuario si falló.
    /// Si falla, la sesión sigue abierta: el estado no cambia y la pantalla actual se mantiene
    /// para poder avisar, en lugar de sacar al usuario de su cuenta.
    @discardableResult
    func signOut() async -> String? {
        do {
            try await logout.execute()
            state = .unauthenticated
            return nil
        } catch {
            if error.isCancellation { return nil }
            AppLogger.error("AuthViewModel.signOut", error)
            return error.userFacingMessage
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

    /// Un fallo de inicio de sesión o registro deja al usuario sin sesión y con un mensaje.
    /// Una cancelación (por ejemplo, cerrar la ventana de Google) no es un fallo.
    private func handleSignInFailure(_ error: Error, context: String) {
        if error.isCancellation {
            state = .unauthenticated
            return
        }
        AppLogger.error(context, error)
        state = .error(error.userFacingMessage)
    }
}
