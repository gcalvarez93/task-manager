//
//  AuthRemoteDataSource.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Features/Auth/Data/DataSources/AuthRemoteDataSource.swift
import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

protocol AuthRemoteDataSourceProtocol {
    func loginWithEmail(email: String, password: String) async throws -> UserModel
    func registerWithEmail(email: String, password: String, name: String) async throws -> UserModel
    func loginWithGoogle() async throws -> UserModel
    func logout() async throws
    func getCurrentUser() -> UserModel?
}

final class AuthRemoteDataSource: AuthRemoteDataSourceProtocol {

    func loginWithEmail(email: String, password: String) async throws -> UserModel {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return mapUser(result.user)
    }

    func registerWithEmail(email: String, password: String, name: String) async throws -> UserModel {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = name
        try await changeRequest.commitChanges()
        return mapUser(result.user)
    }

    func loginWithGoogle() async throws -> UserModel {
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
    }

    func logout() async throws {
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
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
}
