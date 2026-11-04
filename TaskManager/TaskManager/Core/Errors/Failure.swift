//
//  Failure.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Core/Errors/Failure.swift
import Foundation

enum Failure: LocalizedError, Equatable {
    case network(String)
    case server(String)
    case auth(String)
    case validation(String)
    case invalidCredentials
    case emailAlreadyInUse
    case weakPassword
    case tooManyRequests
    case unknown

    /// Texto técnico, en inglés, pensado para logs y depuración.
    /// No se muestra al usuario: para eso está `userMessage`.
    var errorDescription: String? {
        switch self {
        case .network(let msg):    return "Network error: \(msg)"
        case .server(let msg):     return "Server error: \(msg)"
        case .auth(let msg):       return "Auth error: \(msg)"
        case .validation(let msg): return msg
        case .invalidCredentials:  return "Invalid credentials"
        case .emailAlreadyInUse:   return "Email already in use"
        case .weakPassword:        return "Weak password"
        case .tooManyRequests:     return "Too many requests"
        case .unknown:             return "An unexpected error occurred"
        }
    }

    /// Mensaje localizado y apto para el usuario. Nunca incluye el detalle técnico
    /// (códigos HTTP, textos de Firebase...), que solo va a los logs.
    /// Las validaciones ya llevan un mensaje localizado desde el caso de uso.
    var userMessage: String {
        switch self {
        case .network:             return String(localized: "error_network")
        case .server:              return String(localized: "error_server")
        case .auth:                return String(localized: "error_auth")
        case .validation(let msg): return msg
        case .invalidCredentials:  return String(localized: "error_invalid_credentials")
        case .emailAlreadyInUse:   return String(localized: "error_email_in_use")
        case .weakPassword:        return String(localized: "error_weak_password")
        case .tooManyRequests:     return String(localized: "error_too_many_requests")
        case .unknown:             return String(localized: "error_unknown")
        }
    }
}

extension Error {
    /// Mensaje para mostrar al usuario. Cualquier error que no sea un `Failure`
    /// se muestra como error genérico, sin exponer su texto.
    var userFacingMessage: String {
        (self as? Failure)?.userMessage ?? Failure.unknown.userMessage
    }

    /// `true` si el error viene de una tarea cancelada (por ejemplo, la vista desapareció
    /// mientras cargaba). No es un fallo real y no debe mostrarse como error.
    var isCancellation: Bool {
        if self is CancellationError { return true }
        if let urlError = self as? URLError, urlError.code == .cancelled { return true }
        return false
    }
}
