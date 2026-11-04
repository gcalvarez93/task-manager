//
//  FirebaseAuthErrorMapperTests.swift
//  TaskManager
//
//  Created by Gabriel Castro on 04/11/2026.
//

// Path: TaskManager/TaskManagerTests/FirebaseAuthErrorMapperTests.swift
import Foundation
import Testing
@testable import TaskManager

/// Prueba solo la traducción de errores de Firebase a `Failure`; no usa la red ni el SDK real.
struct FirebaseAuthErrorMapperTests {

    // Dominio y códigos documentados de Firebase Auth (AuthErrorDomain / AuthErrorCode).
    private let domain = "FIRAuthErrorDomain"
    private let invalidCredential = 17004
    private let emailAlreadyInUse = 17007
    private let invalidEmail = 17008
    private let wrongPassword = 17009
    private let tooManyRequests = 17010
    private let userNotFound = 17011
    private let networkError = 17020
    private let weakPassword = 17026
    private let internalError = 17999

    private func firebaseError(code: Int) -> NSError {
        NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: "detalle técnico"])
    }

    private func mapped(_ error: Error) -> Failure? {
        FirebaseAuthErrorMapper.map(error) as? Failure
    }

    @Test func credentialErrorsMapToInvalidCredentials() {
        for code in [invalidCredential, wrongPassword, userNotFound] {
            #expect(mapped(firebaseError(code: code)) == Failure.invalidCredentials)
        }
    }

    @Test func invalidEmailMapsToAValidationMessage() {
        let failure = mapped(firebaseError(code: invalidEmail))

        #expect(failure == Failure.validation(String(localized: "error_invalid_email")))
    }

    @Test func emailAlreadyInUseMapsToItsOwnFailure() {
        #expect(mapped(firebaseError(code: emailAlreadyInUse)) == Failure.emailAlreadyInUse)
    }

    @Test func weakPasswordMapsToItsOwnFailure() {
        #expect(mapped(firebaseError(code: weakPassword)) == Failure.weakPassword)
    }

    @Test func tooManyRequestsMapsToItsOwnFailure() {
        #expect(mapped(firebaseError(code: tooManyRequests)) == Failure.tooManyRequests)
    }

    @Test func networkErrorMapsToNetwork() {
        #expect(mapped(firebaseError(code: networkError)) == Failure.network("detalle técnico"))
    }

    @Test func unlistedFirebaseErrorsMapToAuthKeepingTheDetailForTheLogs() {
        #expect(mapped(firebaseError(code: internalError)) == Failure.auth("detalle técnico"))
    }

    @Test func errorsFromAnotherDomainMapToAuth() {
        let foreign = NSError(domain: "OtroDominio", code: wrongPassword, userInfo: [NSLocalizedDescriptionKey: "otro"])

        #expect(mapped(foreign) == Failure.auth("otro"))
    }

    @Test func aCancellationPassesThroughUnchanged() {
        #expect(FirebaseAuthErrorMapper.map(CancellationError()) is CancellationError)
    }

    @Test func aFailurePassesThroughUnchanged() {
        #expect(mapped(Failure.server("HTTP 500")) == Failure.server("HTTP 500"))
    }

    @Test func theUserNeverSeesTheTechnicalDetailOfAMappedError() {
        let failure = mapped(firebaseError(code: internalError))

        #expect(failure?.userMessage.contains("detalle técnico") == false)
    }
}
