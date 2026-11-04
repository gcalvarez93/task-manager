//
//  FailureTests.swift
//  TaskManager
//
//  Created by Gabriel Castro on 04/11/2026.
//

// Path: TaskManager/TaskManagerTests/FailureTests.swift
import Foundation
import Testing
@testable import TaskManager

struct FailureTests {

    private struct OtherError: Error {}

    // MARK: - Mensaje para el usuario

    @Test func technicalDetailNeverReachesTheUserMessage() {
        let detail = "NSURLErrorDomain -1009 secret-detail"
        let failures: [Failure] = [
            .network(detail), .server(detail), .auth(detail)
        ]

        for failure in failures {
            #expect(!failure.userMessage.contains(detail))
        }
    }

    @Test func validationShowsItsOwnMessage() {
        #expect(Failure.validation("Mensaje propio").userMessage == "Mensaje propio")
    }

    @Test func everyFailureHasANonEmptyUserMessage() {
        let failures: [Failure] = [
            .network("x"), .server("x"), .auth("x"), .validation("x"),
            .invalidCredentials, .emailAlreadyInUse, .weakPassword, .tooManyRequests, .unknown
        ]

        for failure in failures {
            #expect(!failure.userMessage.isEmpty)
        }
    }

    @Test func theLocalizedMessagesAreInTheCatalog() {
        // Si una clave falta en el catálogo, `String(localized:)` devuelve la propia clave.
        let keys: [(String, Failure)] = [
            ("error_network", .network("x")),
            ("error_server", .server("x")),
            ("error_auth", .auth("x")),
            ("error_invalid_credentials", .invalidCredentials),
            ("error_email_in_use", .emailAlreadyInUse),
            ("error_weak_password", .weakPassword),
            ("error_too_many_requests", .tooManyRequests),
            ("error_unknown", .unknown)
        ]

        for (key, failure) in keys {
            #expect(failure.userMessage != key)
        }
    }

    // MARK: - Texto técnico para logs

    @Test func theTechnicalDescriptionKeepsTheDetailForTheLogs() {
        #expect(Failure.server("HTTP 500").errorDescription == "Server error: HTTP 500")
        #expect(Failure.network("offline").errorDescription == "Network error: offline")
    }

    // MARK: - Cualquier error

    @Test func aFailureUsesItsOwnUserMessage() {
        let error: Error = Failure.weakPassword

        #expect(error.userFacingMessage == Failure.weakPassword.userMessage)
    }

    @Test func otherErrorsUseTheGenericMessageWithoutExposingTheirText() {
        let error: Error = OtherError()

        #expect(error.userFacingMessage == Failure.unknown.userMessage)
    }

    // MARK: - Cancelación

    @Test func cancellationErrorsAreRecognised() {
        #expect((CancellationError() as Error).isCancellation)
        #expect((URLError(.cancelled) as Error).isCancellation)
    }

    @Test func otherErrorsAreNotCancellations() {
        #expect(!(URLError(.timedOut) as Error).isCancellation)
        #expect(!(Failure.network("x") as Error).isCancellation)
        #expect(!(OtherError() as Error).isCancellation)
    }
}
