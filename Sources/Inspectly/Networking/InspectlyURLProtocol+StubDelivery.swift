//
//  InspectlyURLProtocol+StubDelivery.swift
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

// MARK: - Stub Delivery

extension InspectlyURLProtocol {
    func handleStubbedResponse(_ stubResponse: StubResponse, for networkRequest: NetworkRequest, stubId: UUID) {
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

    func errorForType(_ errorType: StubErrorType) -> NSError {
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
