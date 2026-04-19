//
//  InspectlyURLProtocol.swift
//  Inspectly
//
//  Created by Agus Cahyono on 18/04/2026.
//  Copyright © 2026 Agus Cahyono. All rights reserved.
//
//  Inspectly is a premium, developer-first HTTP interception and mocking
//  library for iOS. It captures, inspects, and mocks network requests with
//  zero configuration and zero dependencies.
//
//  Compatible with URLSession, Alamofire, AFNetworking, and any networking
//  library built on top of Foundation networking.
//
//  Repository:
//  https://github.com/balitax/Inspectly
//

import Foundation

// MARK: - Inspectly URL Protocol
///
/// A custom URLProtocol that intercepts HTTP(S) requests and optionally returns
/// stub responses. This is the primary interception mechanism for URLSession-based networking.
///
/// ## Integration Guide
///
/// ### Step 1: Register the Protocol
/// ```swift
/// // In your AppDelegate or App init:
/// URLProtocol.registerClass(InspectlyURLProtocol.self)
/// ```
///
/// ### Step 2: For URLSession with custom configuration:
/// ```swift
/// let config = URLSessionConfiguration.default
/// config.protocolClasses = [InspectlyURLProtocol.self] + (config.protocolClasses ?? [])
/// let session = URLSession(configuration: config)
/// ```
///
/// ### Step 3: Set the stub repository (for stubbing support):
/// ```swift
/// InspectlyURLProtocol.stubRepository = myStubRepository
/// InspectlyURLProtocol.onRequestCaptured = { request in
///     // Handle captured request (e.g., send to RequestRepository)
/// }
/// ```

final class InspectlyURLProtocol: URLProtocol {

    // MARK: - Static Configuration

    /// Repository for looking up stubs. Set this before registering the protocol.
    static var stubRepository: StubRepositoryProtocol?

    /// Callback when a request is captured. Use this to log requests.
    static var onRequestCaptured: ((NetworkRequest) -> Void)?

    /// Whether stubbing is globally enabled.
    static var isStubEnabled: Bool = false

    /// Whether logging is enabled.
    static var isLoggingEnabled: Bool = true

    /// Hosts to ignore (will not be intercepted).
    static var ignoredHosts: Set<String> = []

    // MARK: - Properties

    private var dataTask: URLSessionDataTask?
    private var capturedRequest: NetworkRequest?
    private var responseData = Data()

    private static let handledKey = "InspectlyURLProtocolHandled"

    // MARK: - URLProtocol Override

    override class func canInit(with request: URLRequest) -> Bool {
        // Prevent infinite loops
        guard URLProtocol.property(forKey: handledKey, in: request) == nil else {
            return false
        }

        // Check if host is ignored
        if let host = request.url?.host, ignoredHosts.contains(host) {
            return false
        }

        return isLoggingEnabled || isStubEnabled
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        // Mark request as handled to prevent re-entry
        guard let mutableRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "InspectlyURLProtocol", code: -1))
            return
        }
        URLProtocol.setProperty(true, forKey: InspectlyURLProtocol.handledKey, in: mutableRequest)

        let startTime = Date()

        // Build NetworkRequest for logging
        let networkRequest = buildNetworkRequest(from: request, timestamp: startTime)
        capturedRequest = networkRequest

        // Check for stub
        if Self.isStubEnabled {
            Task {
                if let stub = await Self.stubRepository?.findMatchingStub(for: networkRequest),
                   let scenario = stub.activeScenario {
                    await Self.stubRepository?.incrementUsageCount(stub.id)
                    handleStubbedResponse(scenario.response, for: networkRequest)
                    return
                }

                // No stub found, proceed with real request
                proceedWithRealRequest(mutableRequest as URLRequest, startTime: startTime)
            }
        } else {
            proceedWithRealRequest(mutableRequest as URLRequest, startTime: startTime)
        }
    }

    override func stopLoading() {
        dataTask?.cancel()
    }

    // MARK: - Private Methods

    private func buildNetworkRequest(from urlRequest: URLRequest, timestamp: Date) -> NetworkRequest {
        let url = urlRequest.url?.absoluteString ?? ""
        let components = URLComponents(string: url)

        let requestHeaders = urlRequest.allHTTPHeaderFields?.map {
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

        return NetworkRequest(
            method: HTTPMethodType(rawValue: urlRequest.httpMethod ?? "GET") ?? .get,
            url: url,
            host: components?.host ?? "",
            path: components?.path ?? "",
            scheme: components?.scheme ?? "https",
            requestHeaders: requestHeaders,
            queryParameters: queryParams,
            requestBody: requestBody,
            timestamp: timestamp
        )
    }

    private func handleStubbedResponse(_ stubResponse: StubResponse, for networkRequest: NetworkRequest) {
        // Simulate delay
        let delay = stubResponse.responseDelay

        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }

            // Handle error types
            if stubResponse.errorType != .none {
                let error = self.errorForType(stubResponse.errorType)
                var updatedRequest = networkRequest
                updatedRequest.status = stubResponse.errorType == .timeout ? .timeout : .serverError
                updatedRequest.isStubbed = true
                updatedRequest.source = .stubbed
                updatedRequest.duration = delay
                updatedRequest.errorMessage = error.localizedDescription
                Self.onRequestCaptured?(updatedRequest)
                self.client?.urlProtocol(self, didFailWithError: error)
                return
            }

            // Build response
            let statusCode = stubResponse.statusCode
            let bodyString = stubResponse.bodyContent
            let bodyData = bodyString.data(using: .utf8) ?? Data()

            let headers = Dictionary(uniqueKeysWithValues: stubResponse.headers.map { ($0.key, $0.value) })

            if let url = self.request.url,
               let httpResponse = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: headers) {

                var updatedRequest = networkRequest
                updatedRequest.statusCode = statusCode
                updatedRequest.isStubbed = true
                updatedRequest.source = .stubbed
                updatedRequest.duration = delay
                updatedRequest.responseBody = ResponseBody(
                    rawString: bodyString,
                    rawData: bodyData,
                    contentType: .json,
                    size: Int64(bodyData.count)
                )
                updatedRequest.status = (200...299).contains(statusCode) ? .success :
                    (400...499).contains(statusCode) ? .clientError : .serverError

                Self.onRequestCaptured?(updatedRequest)

                self.client?.urlProtocol(self, didReceive: httpResponse, cacheStoragePolicy: .notAllowed)
                self.client?.urlProtocol(self, didLoad: bodyData)
                self.client?.urlProtocolDidFinishLoading(self)
            }
        }
    }

    private func proceedWithRealRequest(_ request: URLRequest, startTime: Date) {
        let session = URLSession(configuration: .default)
        dataTask = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                var updatedRequest = self.capturedRequest!
                updatedRequest.duration = Date().timeIntervalSince(startTime)
                updatedRequest.status = .unknown
                updatedRequest.errorMessage = error.localizedDescription
                Self.onRequestCaptured?(updatedRequest)

                self.client?.urlProtocol(self, didFailWithError: error)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                var updatedRequest = self.capturedRequest!
                updatedRequest.statusCode = httpResponse.statusCode
                updatedRequest.duration = Date().timeIntervalSince(startTime)

                let responseHeadersList = httpResponse.allHeaderFields.map {
                    RequestHeader(key: "\($0.key)", value: "\($0.value)")
                }
                updatedRequest.responseHeaders = responseHeadersList

                if let data = data {
                    updatedRequest.responseBody = ResponseBody(
                        rawString: String(data: data, encoding: .utf8),
                        rawData: data,
                        contentType: .json,
                        size: Int64(data.count)
                    )
                    updatedRequest.responseSize = Int64(data.count)
                }

                updatedRequest.status = (200...299).contains(httpResponse.statusCode) ? .success :
                    (400...499).contains(httpResponse.statusCode) ? .clientError : .serverError

                updatedRequest.completedAt = Date()
                Self.onRequestCaptured?(updatedRequest)

                self.client?.urlProtocol(self, didReceive: httpResponse, cacheStoragePolicy: .notAllowed)
            }

            if let data = data {
                self.client?.urlProtocol(self, didLoad: data)
            }

            self.client?.urlProtocolDidFinishLoading(self)
        }
        dataTask?.resume()
    }

    private func errorForType(_ errorType: StubErrorType) -> NSError {
        switch errorType {
        case .timeout:
            return NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: [
                NSLocalizedDescriptionKey: "The request timed out."
            ])
        case .noInternet:
            return NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: [
                NSLocalizedDescriptionKey: "The Internet connection appears to be offline."
            ])
        default:
            return NSError(domain: "InspectlyStub", code: errorType.statusCode ?? -1, userInfo: [
                NSLocalizedDescriptionKey: errorType.displayName
            ])
        }
    }
}
