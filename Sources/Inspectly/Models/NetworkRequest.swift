//
//  NetworkRequest.swift
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

// MARK: - HTTP Method

enum HTTPMethodType: String, Codable, CaseIterable, Identifiable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
    case options = "OPTIONS"

    var id: String { rawValue }

    var displayColor: String {
        switch self {
        case .get: return "methodGET"
        case .post: return "methodPOST"
        case .put: return "methodPUT"
        case .patch: return "methodPATCH"
        case .delete: return "methodDELETE"
        case .head: return "methodHEAD"
        case .options: return "methodOPTIONS"
        }
    }
}

// MARK: - Request Status

enum RequestStatus: String, Codable {
    case success
    case clientError
    case serverError
    case timeout
    case noInternet
    case cancelled
    case unknown

    var displayName: String {
        switch self {
        case .success: return "Success"
        case .clientError: return "Client Error"
        case .serverError: return "Server Error"
        case .timeout: return "Timeout"
        case .noInternet: return "No Internet"
        case .cancelled: return "Cancelled"
        case .unknown: return "Unknown"
        }
    }

    var iconName: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .clientError: return "exclamationmark.triangle.fill"
        case .serverError: return "xmark.octagon.fill"
        case .timeout: return "clock.badge.exclamationmark"
        case .noInternet: return "wifi.slash"
        case .cancelled: return "nosign"
        case .unknown: return "questionmark.circle"
        }
    }
}

// MARK: - Content Type

enum ContentType: String, Codable {
    case json = "application/json"
    case xml = "application/xml"
    case formURLEncoded = "application/x-www-form-urlencoded"
    case multipartFormData = "multipart/form-data"
    case plainText = "text/plain"
    case html = "text/html"
    case graphql = "application/graphql"
    case octetStream = "application/octet-stream"
    case unknown = "unknown"

    var displayName: String {
        switch self {
        case .json: return "JSON"
        case .xml: return "XML"
        case .formURLEncoded: return "Form URL Encoded"
        case .multipartFormData: return "Multipart"
        case .plainText: return "Plain Text"
        case .html: return "HTML"
        case .graphql: return "GraphQL"
        case .octetStream: return "Binary"
        case .unknown: return "Unknown"
        }
    }

    var iconName: String {
        switch self {
        case .json: return "curlybraces"
        case .xml: return "chevron.left.forwardslash.chevron.right"
        case .formURLEncoded: return "list.bullet.rectangle"
        case .multipartFormData: return "doc.on.doc"
        case .plainText: return "text.alignleft"
        case .html: return "globe"
        case .graphql: return "point.3.connected.trianglepath.dotted"
        case .octetStream: return "doc.zipper"
        case .unknown: return "questionmark.square"
        }
    }
}

// MARK: - Timeline Event

public struct TimelineEvent: Identifiable, Codable {
    public let id: UUID
    let name: String
    let timestamp: Date
    let duration: TimeInterval?
    let detail: String?

    init(
        id: UUID = UUID(),
        name: String,
        timestamp: Date,
        duration: TimeInterval? = nil,
        detail: String? = nil
    ) {
        self.id = id
        self.name = name
        self.timestamp = timestamp
        self.duration = duration
        self.detail = detail
    }
}

// MARK: - Network Request

public struct NetworkRequest: Identifiable, Codable, Equatable, Hashable {
    public let id: UUID
    var method: HTTPMethodType
    var url: String
    var host: String
    var path: String
    var scheme: String
    var statusCode: Int?
    var requestHeaders: [RequestHeader]
    var responseHeaders: [RequestHeader]
    var queryParameters: [QueryParameter]
    var requestBody: RequestBody?
    var responseBody: ResponseBody?
    var requestContentType: ContentType
    var responseContentType: ContentType
    var duration: TimeInterval?
    var requestSize: Int64?
    var responseSize: Int64?
    var timestamp: Date
    var completedAt: Date?
    var status: RequestStatus
    var isStubbed: Bool
    var isPinned: Bool
    var isFavorite: Bool
    var tags: [RequestTag]
    var timelineEvents: [TimelineEvent]
    var errorMessage: String?
    var stubScenarioName: String?
    var source: RequestSource

    init(
        id: UUID = UUID(),
        method: HTTPMethodType,
        url: String,
        host: String = "",
        path: String = "",
        scheme: String = "https",
        statusCode: Int? = nil,
        requestHeaders: [RequestHeader] = [],
        responseHeaders: [RequestHeader] = [],
        queryParameters: [QueryParameter] = [],
        requestBody: RequestBody? = nil,
        responseBody: ResponseBody? = nil,
        requestContentType: ContentType = .json,
        responseContentType: ContentType = .json,
        duration: TimeInterval? = nil,
        requestSize: Int64? = nil,
        responseSize: Int64? = nil,
        timestamp: Date = Date(),
        completedAt: Date? = nil,
        status: RequestStatus = .success,
        isStubbed: Bool = false,
        isPinned: Bool = false,
        isFavorite: Bool = false,
        tags: [RequestTag] = [],
        timelineEvents: [TimelineEvent] = [],
        errorMessage: String? = nil,
        stubScenarioName: String? = nil,
        source: RequestSource = .real
    ) {
        self.id = id
        self.method = method
        self.url = url
        self.host = host
        self.path = path
        self.scheme = scheme
        self.statusCode = statusCode
        self.requestHeaders = requestHeaders
        self.responseHeaders = responseHeaders
        self.queryParameters = queryParameters
        self.requestBody = requestBody
        self.responseBody = responseBody
        self.requestContentType = requestContentType
        self.responseContentType = responseContentType
        self.duration = duration
        self.requestSize = requestSize
        self.responseSize = responseSize
        self.timestamp = timestamp
        self.completedAt = completedAt
        self.status = status
        self.isStubbed = isStubbed
        self.isPinned = isPinned
        self.isFavorite = isFavorite
        self.tags = tags
        self.timelineEvents = timelineEvents
        self.errorMessage = errorMessage
        self.stubScenarioName = stubScenarioName
        self.source = source
    }

    // MARK: - Computed Properties

    var isSuccess: Bool {
        guard let code = statusCode else { return false }
        return (200...299).contains(code)
    }

    var isClientError: Bool {
        guard let code = statusCode else { return false }
        return (400...499).contains(code)
    }

    var isServerError: Bool {
        guard let code = statusCode else { return false }
        return (500...599).contains(code)
    }

    var isError: Bool {
        isClientError || isServerError || status == .timeout || status == .noInternet
    }

    var formattedDuration: String {
        guard let duration = duration else { return "—" }
        if duration < 1 {
            return String(format: "%.0fms", duration * 1000)
        } else {
            return String(format: "%.2fs", duration)
        }
    }

    var shortURL: String {
        if let components = URLComponents(string: url) {
            return components.path
        }
        return url
    }

    var statusCodeDisplay: String {
        guard let code = statusCode else { return "—" }
        return "\(code)"
    }

    var curlCommand: String {
        var components: [String] = ["curl"]
        components.append("-X \(method.rawValue)")

        for header in requestHeaders {
            components.append("-H '\(header.key): \(header.value)'")
        }

        if let body = requestBody?.rawString, !body.isEmpty {
            let escaped = body.replacingOccurrences(of: "'", with: "'\\''")
            components.append("-d '\(escaped)'")
        }

        components.append("'\(url)'")
        return components.joined(separator: " \\\n  ")
    }

    // MARK: - Equatable & Hashable

    public static func == (lhs: NetworkRequest, rhs: NetworkRequest) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // MARK: - Stub Conversion

    /// Converts this request into a RequestStub for mocking
    func toStub() -> RequestStub {
        let matchRule = StubMatchRule(
            method: method,
            urlPath: nil,
            fullURL: url, // Set full URL for exact matching
            queryParameters: queryParameters,
            headers: requestHeaders
        )

        let scenario = StubScenario(
            name: "Original Capture",
            description: "Default scenario imported from real request capture",
            response: StubResponse(
                statusCode: statusCode ?? 200,
                headers: responseHeaders,
                jsonBody: responseBody?.rawString,
                plainTextBody: responseBody?.contentType == .plainText ? responseBody?.rawString : nil
            ),
            isActive: true
        )

        return RequestStub(
            name: "Stub for \(path)",
            description: "Imported from \(method.rawValue) capture",
            matchRule: matchRule,
            scenarios: [scenario]
        )
    }
}

// MARK: - Request Source

enum RequestSource: String, Codable {
    case real
    case stubbed
    case intercepted

    var displayName: String {
        switch self {
        case .real: return "Live"
        case .stubbed: return "Stubbed"
        case .intercepted: return "Intercepted"
        }
    }

    var iconName: String {
        switch self {
        case .real: return "antenna.radiowaves.left.and.right"
        case .stubbed: return "hammer.fill"
        case .intercepted: return "eye.fill"
        }
    }
}
