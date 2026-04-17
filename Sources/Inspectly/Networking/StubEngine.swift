//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation

// MARK: - Stub Engine
///
/// The StubEngine evaluates incoming requests against registered stubs
/// and returns matching stub responses. This is the core matching logic used
/// by both URLProtocol and Alamofire interceptors.

final class StubEngine {

    private let stubRepository: StubRepositoryProtocol

    init(stubRepository: StubRepositoryProtocol) {
        self.stubRepository = stubRepository
    }

    /// Evaluate a network request against all registered stubs.
    /// Returns the matching stub and its active scenario if found.
    func evaluate(_ request: NetworkRequest) async -> (stub: RequestStub, scenario: StubScenario)? {
        let stubs = await stubRepository.getAllStubs()

        for stub in stubs where stub.isEnabled {
            if stub.matchRule.matches(request), let scenario = stub.activeScenario {
                await stubRepository.incrementUsageCount(stub.id)
                return (stub, scenario)
            }
        }
        return nil
    }

    /// Build a URLResponse and Data from a StubResponse.
    func buildResponse(
        from stubResponse: StubResponse,
        originalURL: URL
    ) -> (response: HTTPURLResponse?, data: Data?) {
        let headers = Dictionary(uniqueKeysWithValues: stubResponse.headers.map { ($0.key, $0.value) })

        let httpResponse = HTTPURLResponse(
            url: originalURL,
            statusCode: stubResponse.statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: headers
        )

        let body = stubResponse.bodyContent
        let data = body.data(using: .utf8)

        return (httpResponse, data)
    }

    /// Get the error for a stub error type (if any).
    func error(for errorType: StubErrorType) -> Error? {
        switch errorType {
        case .none:
            return nil
        case .timeout:
            return URLError(.timedOut)
        case .noInternet:
            return URLError(.notConnectedToInternet)
        case .unauthorized:
            return URLError(.userAuthenticationRequired)
        case .forbidden:
            return URLError(.noPermissionsToReadFile)
        case .notFound:
            return URLError(.fileDoesNotExist)
        case .internalServerError, .badGateway, .serviceUnavailable:
            return URLError(.badServerResponse)
        }
    }

    /// Validate a stub's JSON response body.
    func validateStubJSON(_ stub: RequestStub) -> [String: Bool] {
        var results: [String: Bool] = [:]
        for scenario in stub.scenarios {
            if let json = scenario.response.jsonBody {
                results[scenario.name] = json.isValidJSON
            } else {
                results[scenario.name] = true
            }
        }
        return results
    }
}
