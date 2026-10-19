// Path: TaskManager/TaskManagerTests/NetworkClientTests.swift
import Foundation
import Testing
@testable import TaskManager

/// Intercepta las peticiones de una `URLSession` de prueba. El estado es
/// estático porque `URLProtocol` instancia la clase por su cuenta; por eso la
/// suite se ejecuta en serie.
nonisolated final class StubURLProtocol: URLProtocol {
    nonisolated(unsafe) static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    nonisolated(unsafe) static var lastRequest: URLRequest?

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.lastRequest = request
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

@MainActor
final class StubTokenProvider: TokenProviderProtocol {
    var result: Result<String, Failure>

    init(result: Result<String, Failure> = .success("test-token")) {
        self.result = result
    }

    func getToken() async throws -> String {
        try result.get()
    }
}

private struct Item: Decodable, Equatable {
    let id: String
    let createdAt: Date
}

@MainActor
@Suite(.serialized)
struct NetworkClientTests {
    private let url = "https://api.test/items"

    private func makeClient(token: Result<String, Failure> = .success("test-token")) -> NetworkClient {
        StubURLProtocol.handler = nil
        StubURLProtocol.lastRequest = nil
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return NetworkClient(
            tokenProvider: StubTokenProvider(result: token),
            session: URLSession(configuration: configuration)
        )
    }

    private func stub(status: Int, body: String = "") {
        StubURLProtocol.handler = { request in
            guard let requestURL = request.url,
                  let response = HTTPURLResponse(
                    url: requestURL,
                    statusCode: status,
                    httpVersion: nil,
                    headerFields: nil
                  ) else {
                throw URLError(.badServerResponse)
            }
            return (response, Data(body.utf8))
        }
    }

    @Test func getSendsTheBearerTokenAndDecodesTheBody() async throws {
        let client = makeClient()
        stub(status: 200, body: #"{"id":"1","createdAt":"2026-01-10T10:00:00Z"}"#)

        let item: Item = try await client.get(url)

        #expect(item.id == "1")
        #expect(StubURLProtocol.lastRequest?.value(forHTTPHeaderField: "Authorization") == "Bearer test-token")
        #expect(StubURLProtocol.lastRequest?.httpMethod == "GET")
    }

    @Test func nonSuccessStatusBecomesAServerFailure() async {
        let client = makeClient()
        stub(status: 500)

        await #expect(throws: Failure.server("Server error: 500")) {
            let _: Item = try await client.get(url)
        }
    }

    @Test func malformedBodyBecomesAServerFailure() async {
        let client = makeClient()
        stub(status: 200, body: "not json")

        await #expect(throws: Failure.server("Unexpected server response")) {
            let _: Item = try await client.get(url)
        }
    }

    @Test func missingTokenFailsBeforeSendingTheRequest() async {
        let client = makeClient(token: .failure(.auth("No authenticated user")))
        stub(status: 200)

        await #expect(throws: Failure.auth("No authenticated user")) {
            let _: Item = try await client.get(url)
        }
        #expect(StubURLProtocol.lastRequest == nil)
    }

    @Test func deleteSucceedsOnNoContent() async throws {
        let client = makeClient()
        stub(status: 204)

        try await client.delete(url)

        #expect(StubURLProtocol.lastRequest?.httpMethod == "DELETE")
    }

    @Test func deleteFailureBecomesAServerFailure() async {
        let client = makeClient()
        stub(status: 404)

        await #expect(throws: Failure.server("Server error: 404")) {
            try await client.delete(url)
        }
    }

    @Test func invalidUrlBecomesANetworkFailure() async {
        let client = makeClient()

        await #expect(throws: Failure.network("Invalid URL: ")) {
            let _: Item = try await client.get("")
        }
    }
}
