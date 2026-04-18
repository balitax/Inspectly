//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation
import Alamofire

// MARK: - Inspectly Event Monitor for Alamofire
///
/// An EventMonitor implementation that captures Alamofire request lifecycle events
/// and logs them to Inspectly's request repository.
///
/// ## Usage
///
/// ```swift
/// import Alamofire
/// import Inspectly
///
/// let session = Session(eventMonitors: [InspectlyEventMonitor(
///     requestRepository: Inspectly.container.requestRepository
/// )])
///
/// session.request("https://api.example.com/users").response { response in
///     // Handle response
/// }
/// ```
///

public final class InspectlyEventMonitor: EventMonitor {

    private let requestRepository: RequestRepositoryProtocol
    private var pendingRequests: [String: NetworkRequest] = [:]

    public init(requestRepository: RequestRepositoryProtocol) {
        self.requestRepository = requestRepository
    }

    // MARK: - EventMonitor Methods

    public func request(_ request: Request, didCreateURLRequest urlRequest: URLRequest) {
        guard InspectlyURLProtocol.isLoggingEnabled else { return }
        
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
            requestBody: requestBody,
            timestamp: Date(),
            timelineEvents: [
                TimelineEvent(name: "Request Created", timestamp: Date())
            ]
        )

        pendingRequests[request.id] = networkRequest
        
        Task {
            await requestRepository.addRequest(networkRequest)
        }
    }

    public func request(_ request: Request, didParseResponse response: AFDataResponse<Any?>) {
        guard InspectlyURLProtocol.isLoggingEnabled else { return }
        
        guard var networkRequest = pendingRequests[request.id] else { return }
        
        let statusCode = response.response?.statusCode
        
        let responseHeaders = response.response?.headers.map {
            RequestHeader(key: $0.name, value: $0.value)
        } ?? []
        
        var responseBody: ResponseBody?
        if let data = response.data {
            responseBody = ResponseBody(
                rawString: String(data: data, encoding: .utf8),
                rawData: data,
                contentType: .json,
                size: Int64(data.count)
            )
        }
        
        networkRequest = NetworkRequest(
            id: networkRequest.id,
            method: networkRequest.method,
            url: networkRequest.url,
            host: networkRequest.host,
            path: networkRequest.path,
            scheme: networkRequest.scheme,
            requestHeaders: networkRequest.requestHeaders,
            queryParameters: networkRequest.queryParameters,
            requestBody: networkRequest.requestBody,
            statusCode: statusCode,
            responseHeaders: responseHeaders,
            responseBody: responseBody,
            timestamp: networkRequest.timestamp,
            endTime: Date(),
            duration: Date().timeIntervalSince(networkRequest.timestamp),
            error: response.error,
            isStubbed: networkRequest.isStubbed,
            timelineEvents: networkRequest.timelineEvents + [
                TimelineEvent(name: "Response Received", timestamp: Date())
            ]
        )
        
        pendingRequests[request.id] = networkRequest
        
        Task {
            await requestRepository.updateRequest(networkRequest)
        }
    }

    public func request(_ request: Request, didFailWithError error: AFError) {
        guard InspectlyURLProtocol.isLoggingEnabled else { return }
        
        guard var networkRequest = pendingRequests[request.id] else { return }
        
        networkRequest = NetworkRequest(
            id: networkRequest.id,
            method: networkRequest.method,
            url: networkRequest.url,
            host: networkRequest.host,
            path: networkRequest.path,
            scheme: networkRequest.scheme,
            requestHeaders: networkRequest.requestHeaders,
            queryParameters: networkRequest.queryParameters,
            requestBody: networkRequest.requestBody,
            statusCode: nil,
            responseHeaders: [],
            responseBody: nil,
            timestamp: networkRequest.timestamp,
            endTime: Date(),
            duration: Date().timeIntervalSince(networkRequest.timestamp),
            error: error.localizedDescription,
            isStubbed: networkRequest.isStubbed,
            timelineEvents: networkRequest.timelineEvents + [
                TimelineEvent(name: "Request Failed", timestamp: Date())
            ]
        )
        
        Task {
            await requestRepository.updateRequest(networkRequest)
        }
    }
}