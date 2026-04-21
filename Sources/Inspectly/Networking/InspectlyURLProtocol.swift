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

    private var dataTask: URLSessionDataTask?
    private var capturedRequest: NetworkRequest?
    private var responseData = Data()
    private var isStopped = false

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

    // MARK: - Private Methods

    private func buildNetworkRequest(from urlRequest: URLRequest, bodyData: Data?, timestamp: Date) -> NetworkRequest {
        let url = urlRequest.url?.absoluteString ?? ""
        let components = URLComponents(string: url)

        let requestHeaders = urlRequest.allHTTPHeaderFields?.map {
            RequestHeader(key: $0.key, value: $0.value)
        } ?? []

        let queryParams = components?.queryItems?.map {
            QueryParameter(key: $0.name, value: $0.value ?? "")
        } ?? []

        let contentType = urlRequest.contentType
        var requestBody: RequestBody?
        if let bodyData = bodyData {
            requestBody = RequestBody(
                rawString: String(data: bodyData, encoding: .utf8),
                rawData: bodyData,
                contentType: contentType,
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
            requestContentType: contentType,
            requestSize: bodyData != nil ? Int64(bodyData!.count) : nil,
            timestamp: timestamp
        )
    }

    private func handleStubbedResponse(_ stubResponse: StubResponse, for networkRequest: NetworkRequest, stubId: UUID) {
        // Simulate delay
        let delay = stubResponse.responseDelay

        waitResponsive(for: delay) { [weak self] in
            guard let self = self else { return }

            // Handle error types
            if stubResponse.errorType != .none {
                let error = self.errorForType(stubResponse.errorType)
                var updatedRequest = networkRequest
                updatedRequest.status = stubResponse.errorType == .timeout ? .timeout : .serverError
                updatedRequest.isStubbed = true
                updatedRequest.stubId = stubId
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
                updatedRequest.stubId = stubId
                updatedRequest.source = .stubbed
                updatedRequest.duration = delay

                let responseContentType = stubResponse.contentType
                updatedRequest.responseContentType = responseContentType

                updatedRequest.responseBody = ResponseBody(
                    rawString: bodyString,
                    rawData: bodyData,
                    contentType: responseContentType,
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
        let throttle = Self.networkThrottlingConfig

        if let failureMode = throttle.failureMode {
            waitResponsive(for: throttle.requestDelay) { [weak self] in
                guard let self = self else { return }
                self.handleSimulatedFailure(failureMode, startTime: startTime)
            }
            return
        }

        waitResponsive(for: throttle.requestDelay) { [weak self] in
            guard let self = self else { return }

            let session = URLSession(configuration: .default)
            self.dataTask = session.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self, !self.isStopped else { return }

                if let error = error {
                    var updatedRequest = self.capturedRequest!
                    updatedRequest.duration = Date().timeIntervalSince(startTime)
                    updatedRequest.status = self.status(for: error)
                    updatedRequest.errorMessage = error.localizedDescription
                    updatedRequest.completedAt = Date()
                    Self.onRequestCaptured?(updatedRequest)

                    self.client?.urlProtocol(self, didFailWithError: error)
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    var updatedRequest = self.capturedRequest!
                    updatedRequest.statusCode = httpResponse.statusCode
                    
                    var responseContentType = httpResponse.contentType
                    
                    let responseHeadersList = httpResponse.allHeaderFields.map {
                        RequestHeader(key: "\($0.key)", value: "\($0.value)")
                    }
                    updatedRequest.responseHeaders = responseHeadersList

                    if let data = data {
                        // Sniff content type from data if header is misleading (e.g. application/json but body is HTML)
                        if let sniffedType = ContentType.sniff(data: data) {
                            responseContentType = sniffedType
                        }
                        
                        updatedRequest.responseBody = ResponseBody(
                            rawString: String(data: data, encoding: .utf8),
                            rawData: data,
                            contentType: responseContentType,
                            size: Int64(data.count)
                        )
                        updatedRequest.responseSize = Int64(data.count)
                    }
                    
                    updatedRequest.responseContentType = responseContentType

                    updatedRequest.status = (200...299).contains(httpResponse.statusCode) ? .success :
                        (400...499).contains(httpResponse.statusCode) ? .clientError : .serverError

                    self.deliverResponse(
                        data: data ?? Data(),
                        response: httpResponse,
                        updatedRequest: updatedRequest,
                        startTime: startTime,
                        bytesPerSecond: throttle.bytesPerSecond
                    )
                    return
                }

                self.client?.urlProtocolDidFinishLoading(self)
            }
            self.dataTask?.resume()
        }
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

    private func deliverResponse(
        data: Data,
        response: HTTPURLResponse,
        updatedRequest: NetworkRequest,
        startTime: Date,
        bytesPerSecond: Double?
    ) {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

        guard let bytesPerSecond, !data.isEmpty else {
            if !data.isEmpty {
                client?.urlProtocol(self, didLoad: data)
            }

            finishResponseDelivery(updatedRequest, startTime: startTime)
            return
        }

        // Use absolute start time for bandwidth calculation to prevent drift
        deliverChunkedData(
            data,
            offset: 0,
            transferStartTime: Date(),
            bytesPerSecond: bytesPerSecond
        ) { [weak self] in
            guard let self = self else { return }
            self.finishResponseDelivery(updatedRequest, startTime: startTime)
        }
    }

    private func finishResponseDelivery(_ request: NetworkRequest, startTime: Date) {
        guard !isStopped else { return }

        var completedRequest = request
        completedRequest.duration = Date().timeIntervalSince(startTime)
        completedRequest.completedAt = Date()

        Self.onRequestCaptured?(completedRequest)
        client?.urlProtocolDidFinishLoading(self)
    }

    private func deliverChunkedData(
        _ data: Data,
        offset: Int,
        transferStartTime: Date,
        bytesPerSecond: Double,
        completion: @escaping () -> Void
    ) {
        guard !isStopped else { return }

        if offset >= data.count {
            completion()
            return
        }

        // Calculate chunk size (approx. 10 chunks per second for smooth delivery)
        let chunkSize = max(1_024, min(16_384, Int(bytesPerSecond / 10)))
        let endIndex = min(offset + chunkSize, data.count)
        let chunk = data.subdata(in: offset..<endIndex)

        client?.urlProtocol(self, didLoad: chunk)

        // Calculate when the NEXT chunk should be delivered based on absolute start time
        // Formula: Time = TotalBytesSent / BytesPerSecond
        let totalBytesSent = Double(endIndex)
        let targetTimeSinceStart = totalBytesSent / bytesPerSecond
        let absoluteTargetTime = transferStartTime.addingTimeInterval(targetTimeSinceStart)
        
        let now = Date()
        let delay = max(0, absoluteTargetTime.timeIntervalSince(now))

        dispatch(after: delay) { [weak self] in
            guard let self = self else { return }
            self.deliverChunkedData(
                data,
                offset: endIndex,
                transferStartTime: transferStartTime,
                bytesPerSecond: bytesPerSecond,
                completion: completion
            )
        }
    }

    private func handleSimulatedFailure(
        _ failureMode: NetworkThrottlingConfiguration.FailureMode,
        startTime: Date
    ) {
        guard let capturedRequest else { return }

        let error = errorForThrottleFailure(failureMode)
        var updatedRequest = capturedRequest
        updatedRequest.duration = Date().timeIntervalSince(startTime)
        updatedRequest.status = status(for: error)
        updatedRequest.errorMessage = error.localizedDescription
        updatedRequest.completedAt = Date()

        Self.onRequestCaptured?(updatedRequest)
        client?.urlProtocol(self, didFailWithError: error)
    }

    private func errorForThrottleFailure(_ failureMode: NetworkThrottlingConfiguration.FailureMode) -> NSError {
        switch failureMode {
        case .dnsFailure:
            return NSError(domain: NSURLErrorDomain, code: NSURLErrorDNSLookupFailed, userInfo: [
                NSLocalizedDescriptionKey: "DNS lookup failed for the requested host."
            ])
        }
    }

    private func status(for error: Error) -> RequestStatus {
        let nsError = error as NSError

        guard nsError.domain == NSURLErrorDomain else {
            return .unknown
        }

        switch nsError.code {
        case NSURLErrorTimedOut:
            return .timeout
        case NSURLErrorCancelled:
            return .cancelled
        case NSURLErrorNotConnectedToInternet, NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost, NSURLErrorDNSLookupFailed:
            return .noInternet
        default:
            return .unknown
        }
    }

    private func dispatch(after delay: TimeInterval, execute block: @escaping () -> Void) {
        guard !isStopped else { return }

        if delay <= 0 {
            block()
            return
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self, !self.isStopped else { return }
            block()
        }
    }

    private func waitResponsive(for delay: TimeInterval, completion: @escaping () -> Void) {
        guard delay > 0 else {
            completion()
            return
        }

        let start = Date()
        func check() {
            guard !isStopped else { return }
            let elapsed = Date().timeIntervalSince(start)
            if elapsed >= delay {
                completion()
            } else {
                let remaining = delay - elapsed
                let nextStep = min(remaining, 0.1) // Check every 100ms
                DispatchQueue.global().asyncAfter(deadline: .now() + nextStep) {
                    check()
                }
            }
        }
        check()
    }
}
