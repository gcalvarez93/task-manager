//
//  AuthRemoteDataSource.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Auth/Data/Datasources/AuthRemoteDataSource.swift
import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

protocol AuthRemoteDataSourceProtocol {
    func loginWithEmail(email: String, password: String) async throws -> UserModel
    func registerWithEmail(email: String, password: String, name: String) async throws -> UserModel
    func loginWithGoogle() async throws -> UserModel
    func logout() async throws
    func updateDisplayName(_ name: String) async throws -> UserModel?
    func getCurrentUser() -> UserModel?
}

final class AuthRemoteDataSource: AuthRemoteDataSourceProtocol {

    // Dominio y código de `GIDSignInError.canceled` (el usuario cierra la ventana de Google).
    private let googleSignInErrorDomain = "com.google.GIDSignIn"
    private let googleSignInCanceledCode = -5

    func loginWithEmail(email: String, password: String) async throws -> UserModel {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return mapUser(result.user)
        } catch {
            throw FirebaseAuthErrorMapper.map(error)
        }
    }

    func registerWithEmail(email: String, password: String, name: String) async throws -> UserModel {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            // La cuenta ya existe y la sesión está abierta. Si solo falla guardar el nombre,
            // no se trata como un fallo de registro: se registra y se continúa.
            do {
                let changeRequest = result.user.createProfileChangeRequest()
                changeRequest.displayName = name
                try await changeRequest.commitChanges()
            } catch {
                AppLogger.error("AuthRemoteDataSource.registerWithEmail.displayName", error)
            }
            return mapUser(result.user)
        } catch {
            throw FirebaseAuthErrorMapper.map(error)
        }
    }

    func loginWithGoogle() async throws -> UserModel {
        do {
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                throw Failure.auth("Missing Firebase client ID")
            }
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config

            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                throw Failure.auth("No root view controller")
            }

            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            guard let idToken = result.user.idToken?.tokenString else {
                throw Failure.auth("Missing Google ID token")
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            let authResult = try await Auth.auth().signIn(with: credential)
            return mapUser(authResult.user)
        } catch {
            throw mapGoogleError(error)
        }
    }

    func logout() async throws {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
        } catch {
            throw FirebaseAuthErrorMapper.map(error)
        }
    }

    /// Actualiza el nombre visible, recarga el usuario y lo devuelve
    /// (`nil` si no hay sesión).
    func updateDisplayName(_ name: String) async throws -> UserModel? {
        guard let user = Auth.auth().currentUser else { return nil }
        do {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name
            try await changeRequest.commitChanges()
            try await user.reload()
            return mapUser(user)
        } catch {
            throw FirebaseAuthErrorMapper.map(error)
        }
    }

    func getCurrentUser() -> UserModel? {
        guard let user = Auth.auth().currentUser else { return nil }
        return mapUser(user)
    }

    private func mapUser(_ user: FirebaseAuth.User) -> UserModel {
        UserModel(
            id: user.uid,
            email: user.email ?? "",
            name: user.displayName,
            photoUrl: user.photoURL?.absoluteString
        )
    }

    /// Si el usuario cierra la ventana de Google no es un fallo: se devuelve como cancelación.
    private func mapGoogleError(_ error: Error) -> Error {
        let nsError = error as NSError
        if nsError.domain == googleSignInErrorDomain, nsError.code == googleSignInCanceledCode {
            return CancellationError()
        }
        return FirebaseAuthErrorMapper.map(error)
    }
}
