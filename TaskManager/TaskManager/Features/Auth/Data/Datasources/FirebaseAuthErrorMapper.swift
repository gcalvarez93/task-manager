//
//  FirebaseAuthErrorMapper.swift
//  TaskManager
//
//  Created by Gabriel Castro on 04/11/2026.
//

// Path: TaskManager/Features/Auth/Data/Datasources/FirebaseAuthErrorMapper.swift
import Foundation
 
/// Traduce los errores de Firebase Auth a `Failure`. No depende del SDK: usa el dominio y los
/// códigos documentados de `AuthErrorDomain`, así que se puede probar sin Firebase.
enum FirebaseAuthErrorMapper {
 
    static let domain = "FIRAuthErrorDomain"
 
    private enum Code {
        static let invalidCredential = 17004
        static let emailAlreadyInUse = 17007
        static let invalidEmail = 17008
        static let wrongPassword = 17009
        static let tooManyRequests = 17010
        static let userNotFound = 17011
        static let networkError = 17020
        static let weakPassword = 17026
    }
 
    /// Devuelve el error ya traducido. Un `Failure` o una cancelación pasan sin cambios;
    /// cualquier otro error desconocido se convierte en `Failure.auth` con su detalle técnico
    /// (que solo se registra en los logs).
    static func map(_ error: Error) -> Error {
        if error is Failure || error is CancellationError { return error }
 
        let nsError = error as NSError
        guard nsError.domain == domain else {
            return Failure.auth(nsError.localizedDescription)
        }
 
        switch nsError.code {
        case Code.invalidCredential, Code.wrongPassword, Code.userNotFound:
            return Failure.invalidCredentials
        case Code.invalidEmail:
            return Failure.validation(String(localized: "error_invalid_email"))
        case Code.emailAlreadyInUse:
            return Failure.emailAlreadyInUse
        case Code.weakPassword:
            return Failure.weakPassword
        case Code.tooManyRequests:
            return Failure.tooManyRequests
        case Code.networkError:
            return Failure.network(nsError.localizedDescription)
        default:
            return Failure.auth(nsError.localizedDescription)
        }
    }
}
