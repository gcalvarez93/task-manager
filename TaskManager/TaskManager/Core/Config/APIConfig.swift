//
//  APIConfig.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Core/Config/APIConfig.swift
import Foundation

enum APIConfig {
    static let baseURL: String = {
        // Inyectado via -DAPI_URL en Build Settings o Info.plist
        if let url = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String {
            return url
        }
        return "http://localhost:5166"
    }()

    // Common
    static var userMe: String { "\(baseURL)/api/common/users/me" }

    // Boards
    static var boards: String { "\(baseURL)/api/tasks/boards" }
    static func board(_ id: String) -> String { "\(baseURL)/api/tasks/boards/\(id)" }

    // Tasks
    static var tasks: String { "\(baseURL)/api/tasks" }
    static func task(_ id: String) -> String { "\(baseURL)/api/tasks/\(id)" }
    static func tasksByBoard(_ boardId: String) -> String { "\(baseURL)/api/tasks?boardId=\(boardId)" }

    // Labels
    static var labels: String { "\(baseURL)/api/tasks/labels" }
    static func label(_ id: String) -> String { "\(baseURL)/api/tasks/labels/\(id)" }
}
