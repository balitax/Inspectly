//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation

// MARK: - Inspectly Event Monitor for Alamofire
///
/// An EventMonitor implementation that captures Alamofire request lifecycle events
/// and logs them to Inspectly's request repository.
///
/// ## Integration Guide
///
/// ```swift
/// import Alamofire
///
/// let inspectlyMonitor = InspectlyEventMonitor(
///     requestRepository: DependencyContainer.shared.requestRepository
/// )
///
/// let session = Session(eventMonitors: [inspectlyMonitor])
///
/// // Now all requests through this session will be captured by Inspectly
/// session.request("https://api.example.com/users").responseDecodable(of: User.self) { response in
///     // Handle response
/// }
/// ```
///
/// ## Notes
/// - This is a sample implementation. In production, import Alamofire and
///   conform to Alamofire's `EventMonitor` protocol.
/// - The protocol methods below mirror Alamofire's EventMonitor API.

public final class InspectlyEventMonitor {

    private let requestRepository: RequestRepositoryProtocol
    private var pendingRequests: [String: NetworkRequest] = [:]

    init(requestRepository: RequestRepositoryProtocol) {
        self.requestRepository = requestRepository
    }

    // MARK: - Alamofire EventMonitor Methods (Sample)

    /// Called when a URLRequest is created from the initial URLRequestConvertible value.
    /// Equivalent to: `func request(_ request: Request, didCreateURLRequest urlRequest: URLRequest)`
    func requestDidCreateURLRequest(_ urlRequest: URLRequest, requestID: String) {
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

        pendingRequests[requestID] = networkRequest
    }

    /// Called when a DataRequest receives a HTTPURLResponse.
    /// Equivalent to: `func request(_ request: DataRequest, didParseResponse response: DataResponse<Data?, AFError>)`
    func requestDidComplete(requestID: String, response: HTTPURLResponse?, data: Data?, error: Error?, duration: TimeInterval) {
        guard var networkRequest = pendingRequests.removeValue(forKey: requestID) else { return }

        networkRequest.statusCode = response?.statusCode
        networkRequest.duration = duration
        networkRequest.completedAt = Date()

        if let response = response {
            networkRequest.responseHeaders = response.allHeaderFields.map {
                RequestHeader(key: "\($0.key)", value: "\($0.value)")
            }
        }

        if let data = data {
            networkRequest.responseBody = ResponseBody(
                rawString: String(data: data, encoding: .utf8),
                rawData: data,
                contentType: .json,
                size: Int64(data.count)
            )
            networkRequest.responseSize = Int64(data.count)
        }

        if let error = error {
            networkRequest.errorMessage = error.localizedDescription
            networkRequest.status = .unknown
        } else if let statusCode = response?.statusCode {
            networkRequest.status = (200...299).contains(statusCode) ? .success :
                (400...499).contains(statusCode) ? .clientError : .serverError
        }

        networkRequest.timelineEvents.append(
            TimelineEvent(name: "Response Received", timestamp: Date(), duration: duration)
        )

        Task {
            await requestRepository.addRequest(networkRequest)
        }
    }
}
