//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation

// MARK: - Inspectly Request Interceptor for Alamofire
///
/// A RequestInterceptor implementation that can intercept Alamofire requests
/// and optionally return stub responses instead of making real network calls.
///
/// ## Integration Guide
///
/// ```swift
/// import Alamofire
///
/// let stubEngine = StubEngine(stubRepository: DependencyContainer.shared.stubRepository)
/// let interceptor = InspectlyRequestInterceptor(stubEngine: stubEngine)
///
/// let session = Session(interceptor: interceptor)
///
/// // Or apply per-request:
/// session.request("https://api.example.com/users", interceptor: interceptor)
///     .responseDecodable(of: [User].self) { response in
///         // This may return stubbed data if a matching stub is active
///     }
/// ```
///
/// ## How Stubbing Works
///
/// 1. When a request is about to be sent, the interceptor checks the StubEngine.
/// 2. If a matching stub is found with an active scenario, the stub response is returned.
/// 3. If no stub matches, the request proceeds normally.
/// 4. The interceptor supports:
///    - Response delay simulation
///    - Fake error injection
///    - Header/body/status code overriding
///    - Per-scenario switching

final class InspectlyRequestInterceptor {

    private let stubEngine: StubEngine
    private let isEnabled: Bool

    init(stubEngine: StubEngine, isEnabled: Bool = true) {
        self.stubEngine = stubEngine
        self.isEnabled = isEnabled
    }

    // MARK: - Alamofire RequestInterceptor Methods (Sample)

    /// Intercepts the request before it is sent.
    /// In Alamofire, this would conform to `RequestAdapter`:
    /// `func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void)`
    func adapt(_ urlRequest: URLRequest) async throws -> URLRequest {
        // You can modify headers, add auth tokens, etc.
        var request = urlRequest
        request.setValue("Inspectly/1.0", forHTTPHeaderField: "X-Inspectly-Version")
        return request
    }

    /// Retries failed requests.
    /// In Alamofire, this would conform to `RequestRetrier`:
    /// `func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void)`
    func retry(for error: Error, retryCount: Int) -> Bool {
        // Simple retry logic — retry up to 2 times for timeout errors
        if retryCount < 2, (error as? URLError)?.code == .timedOut {
            return true
        }
        return false
    }

    // MARK: - Stub Interception

    /// Check if a request should be stubbed. Returns stub response data if matched.
    func interceptForStub(_ urlRequest: URLRequest) async -> StubInterceptionResult? {
        guard isEnabled else { return nil }

        let url = urlRequest.url?.absoluteString ?? ""
        let components = URLComponents(string: url)

        let headers = urlRequest.allHTTPHeaderFields?.map {
            RequestHeader(key: $0.key, value: $0.value)
        } ?? []

        let queryParams = components?.queryItems?.map {
            QueryParameter(key: $0.name, value: $0.value ?? "")
        } ?? []

        var requestBody: RequestBody?
        if let bodyData = urlRequest.httpBody {
            requestBody = RequestBody(
                rawString: String(data: bodyData, encoding: .utf8),
                rawData: bodyData,
                contentType: .json,
                size: Int64(bodyData.count)
            )
        }

        let networkRequest = NetworkRequest(
            method: HTTPMethodType(rawValue: urlRequest.httpMethod ?? "GET") ?? .get,
            url: url,
            host: components?.host ?? "",
            path: components?.path ?? "",
            scheme: components?.scheme ?? "https",
            requestHeaders: headers,
            queryParameters: queryParams,
            requestBody: requestBody
        )

        guard let result = await stubEngine.evaluate(networkRequest) else {
            return nil
        }

        let response = result.scenario.response

        return StubInterceptionResult(
            statusCode: response.statusCode,
            headers: Dictionary(uniqueKeysWithValues: response.headers.map { ($0.key, $0.value) }),
            body: response.bodyContent.data(using: .utf8),
            delay: response.responseDelay,
            error: stubEngine.error(for: response.errorType),
            stubName: result.stub.name,
            scenarioName: result.scenario.name
        )
    }
}

// MARK: - Stub Interception Result

struct StubInterceptionResult {
    let statusCode: Int
    let headers: [String: String]
    let body: Data?
    let delay: TimeInterval
    let error: Error?
    let stubName: String
    let scenarioName: String
}
