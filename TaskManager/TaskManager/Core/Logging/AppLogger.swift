//
//  AppLogger.swift
//  TaskManager
//
//  Created by Gabriel Castro on 19/10/2026.
//

// Path: TaskManager/Core/Logging/AppLogger.swift
import Foundation
import Logging

/// Fachada sobre `swift-log`. Centraliza la etiqueta y el formato para que el
/// resto de la app no dependa del backend de logging concreto.
nonisolated enum AppLogger {
    private static let logger = Logger(label: "com.castrodev.TaskManager")

    static func info(_ message: String) {
        logger.info("\(message)")
    }

    static func warning(_ message: String) {
        logger.warning("\(message)")
    }

    /// Registra un error con su contexto (`Clase.metodo`). El detalle técnico
    /// va en los metadatos; nunca se muestra al usuario.
    static func error(_ context: String, _ error: Error) {
        logger.error(
            "\(context) failed: \(error.localizedDescription)",
            metadata: ["error": .string(String(describing: error))]
        )
    }
}
