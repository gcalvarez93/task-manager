//
//  Failure.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Core/Errors/Failure.swift
import Foundation

enum Failure: LocalizedError {
    case network(String)
    case server(String)
    case auth(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .network(let message): return message
        case .server(let message): return message
        case .auth(let message): return message
        case .unknown: return "An unexpected error occurred"
        }
    }
}
