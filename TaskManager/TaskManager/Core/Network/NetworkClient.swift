//
//  NetworkClient.swift
//  TaskManager
//
//  Created by Gabriel Castro on 09/06/2026.
//

// Path: TaskManager/Core/Network/NetworkClient.swift
import Foundation

protocol NetworkClientProtocol {
    func get<T: Decodable>(_ url: String) async throws -> T
    func post<T: Decodable, B: Encodable>(_ url: String, body: B) async throws -> T
    func put<T: Decodable, B: Encodable>(_ url: String, body: B) async throws -> T
    func delete(_ url: String) async throws
}

final class NetworkClient: NetworkClientProtocol {
    static let shared = NetworkClient()
    private let tokenProvider: TokenProviderProtocol
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        tokenProvider: TokenProviderProtocol = FirebaseTokenProvider(),
        session: URLSession = .shared
    ) {
        self.tokenProvider = tokenProvider
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    func get<T: Decodable>(_ url: String) async throws -> T {
        let request = try await buildRequest(url: url, method: "GET")
        return try await perform(request)
    }

    func post<T: Decodable, B: Encodable>(_ url: String, body: B) async throws -> T {
        var request = try await buildRequest(url: url, method: "POST")
        request.httpBody = try JSONEncoder().encode(body)
        return try await perform(request)
    }

    func put<T: Decodable, B: Encodable>(_ url: String, body: B) async throws -> T {
        var request = try await buildRequest(url: url, method: "PUT")
        request.httpBody = try JSONEncoder().encode(body)
        return try await perform(request)
    }

    func delete(_ url: String) async throws {
        let request = try await buildRequest(url: url, method: "DELETE")
        _ = try await send(request)
    }

    private func buildRequest(url: String, method: String) async throws -> URLRequest {
        guard let requestURL = URL(string: url) else {
            throw Failure.network("Invalid URL: \(url)")
        }
        var request = URLRequest(url: requestURL)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let token = try await tokenProvider.getToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let data = try await send(request)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            AppLogger.error("NetworkClient.decode", error)
            throw Failure.server("Unexpected server response")
        }
    }

    /// Ejecuta la petición y valida el código HTTP. Registra los fallos con
    /// método y ruta, pero nunca con la cabecera de autorización.
    private func send(_ request: URLRequest) async throws -> Data {
        let method = request.httpMethod ?? "?"
        let path = request.url?.path ?? ""

        let result: (Data, URLResponse)
        do {
            result = try await session.data(for: request)
        } catch let error as URLError where error.code == .cancelled {
            throw error
        } catch {
            AppLogger.error("NetworkClient.\(method) \(path)", error)
            throw Failure.network(error.localizedDescription)
        }

        guard let httpResponse = result.1 as? HTTPURLResponse else {
            throw Failure.network("Invalid response")
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            AppLogger.warning("\(method) \(path) -> HTTP \(httpResponse.statusCode)")
            throw Failure.server("Server error: \(httpResponse.statusCode)")
        }
        return result.0
    }
}
