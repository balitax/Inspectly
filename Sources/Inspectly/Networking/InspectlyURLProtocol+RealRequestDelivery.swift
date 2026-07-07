//
//  InspectlyURLProtocol+RealRequestDelivery.swift
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

// MARK: - Real Request Delivery

extension InspectlyURLProtocol {
    func proceedWithRealRequest(_ request: URLRequest, startTime: Date) {
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

            self.dataTask = Self.internalSession.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self, !self.isStopped else { return }

                if let error = error {
                    guard let captured = self.capturedRequest else {
                        self.client?.urlProtocol(self, didFailWithError: error)
                        return
                    }
                    var updatedRequest = captured
                    updatedRequest.duration = Date().timeIntervalSince(startTime)
                    updatedRequest.status = self.status(for: error)
                    updatedRequest.errorMessage = error.localizedDescription
                    updatedRequest.completedAt = Date()
                    Self.onRequestCaptured?(updatedRequest)

                    self.client?.urlProtocol(self, didFailWithError: error)
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    guard let captured = self.capturedRequest else {
                        self.client?.urlProtocolDidFinishLoading(self)
                        return
                    }
                    var updatedRequest = captured
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

    func deliverResponse(
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

    func finishResponseDelivery(_ request: NetworkRequest, startTime: Date) {
        guard !isStopped else { return }

        var completedRequest = request
        completedRequest.duration = Date().timeIntervalSince(startTime)
        completedRequest.completedAt = Date()

        Self.onRequestCaptured?(completedRequest)
        client?.urlProtocolDidFinishLoading(self)
    }

    func deliverChunkedData(
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

    func handleSimulatedFailure(
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

    func errorForThrottleFailure(_ failureMode: NetworkThrottlingConfiguration.FailureMode) -> NSError {
        switch failureMode {
        case .dnsFailure:
            return NSError(domain: NSURLErrorDomain, code: NSURLErrorDNSLookupFailed, userInfo: [
                NSLocalizedDescriptionKey: "DNS lookup failed for the requested host."
            ])
        }
    }

    func status(for error: Error) -> RequestStatus {
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
}
