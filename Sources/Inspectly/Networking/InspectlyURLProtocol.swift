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

    /// Active network throttling configuration for real requests.
    static var networkThrottlingConfig: NetworkThrottlingConfiguration = NetworkThrottlingConfiguration()

    /// Hosts to ignore (will not be intercepted).
    static var ignoredHosts: Set<String> = []

    // MARK: - Properties

    // Not `private`: read/written from the InspectlyURLProtocol+*.swift extensions
    // in this target, which need file-private-equivalent access across files.
    var dataTask: URLSessionDataTask?
    var capturedRequest: NetworkRequest?
    var isStopped = false

    private static let handledKey = "InspectlyURLProtocolHandled"

    /// Shared internal session reused across all requests to avoid creating a new
    /// URLSession (and its connection pool) per request. Requests sent through this
    /// session already carry the `handledKey` marker, so InspectlyURLProtocol's
    /// `canInit` returns false for them — preventing infinite interception loops.
    static let internalSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 300
        return URLSession(configuration: config)
    }()

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
        isStopped = false

        // Extract body data (this handles streams too)
        var urlRequest = self.request
        let bodyData = urlRequest.extractBodyData()

        // Mark request as handled to prevent re-entry
        guard let mutableRequest = (urlRequest as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "InspectlyURLProtocol", code: -1))
            return
        }
        URLProtocol.setProperty(true, forKey: InspectlyURLProtocol.handledKey, in: mutableRequest)

        let startTime = Date()
        let finalRequest = mutableRequest as URLRequest

        // Build NetworkRequest for logging
        let networkRequest = buildNetworkRequest(from: finalRequest, bodyData: bodyData, timestamp: startTime)
        capturedRequest = networkRequest

        // Check for stub
        if Self.isStubEnabled {
            Task {
                if let stub = await Self.stubRepository?.findMatchingStub(for: networkRequest),
                   let scenario = stub.activeScenario {
                    await Self.stubRepository?.incrementUsageCount(stub.id)
                    handleStubbedResponse(scenario.response, for: networkRequest, stubId: stub.id)
                    return
                }

                // No stub found, proceed with real request
                proceedWithRealRequest(finalRequest, startTime: startTime)
            }
        } else {
            proceedWithRealRequest(finalRequest, startTime: startTime)
        }
    }

    override func stopLoading() {
        isStopped = true
        dataTask?.cancel()
    }
}
