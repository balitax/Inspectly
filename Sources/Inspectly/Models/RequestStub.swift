//
//  RequestStub.swift
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

// MARK: - Stub Error Type

enum StubErrorType: String, Codable, CaseIterable, Identifiable {
    case none
    case timeout
    case noInternet
    case unauthorized
    case forbidden
    case notFound
    case internalServerError
    case badGateway
    case serviceUnavailable

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: return "No Error"
        case .timeout: return "Timeout"
        case .noInternet: return "No Internet"
        case .unauthorized: return "401 Unauthorized"
        case .forbidden: return "403 Forbidden"
        case .notFound: return "404 Not Found"
        case .internalServerError: return "500 Internal Server Error"
        case .badGateway: return "502 Bad Gateway"
        case .serviceUnavailable: return "503 Service Unavailable"
        }
    }

    var statusCode: Int? {
        switch self {
        case .none: return nil
        case .timeout: return nil
        case .noInternet: return nil
        case .unauthorized: return 401
        case .forbidden: return 403
        case .notFound: return 404
        case .internalServerError: return 500
        case .badGateway: return 502
        case .serviceUnavailable: return 503
        }
    }

    var iconName: String {
        switch self {
        case .none: return "checkmark.circle"
        case .timeout: return "clock.badge.exclamationmark"
        case .noInternet: return "wifi.slash"
        case .unauthorized: return "lock.fill"
        case .forbidden: return "hand.raised.fill"
        case .notFound: return "magnifyingglass"
        case .internalServerError: return "server.rack"
        case .badGateway: return "arrow.triangle.2.circlepath"
        case .serviceUnavailable: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - Stub Match Rule

public struct StubMatchRule: Codable, Identifiable {
    public let id: UUID
    var method: HTTPMethodType?
    var urlPath: String?
    var fullURL: String?
    var queryParameters: [QueryParameter]
    var headers: [RequestHeader]
    var bodyContains: String?

    init(
        id: UUID = UUID(),
        method: HTTPMethodType? = nil,
        urlPath: String? = nil,
        fullURL: String? = nil,
        queryParameters: [QueryParameter] = [],
        headers: [RequestHeader] = [],
        bodyContains: String? = nil
    ) {
        self.id = id
        self.method = method
        self.urlPath = urlPath
        self.fullURL = fullURL
        self.queryParameters = queryParameters
        self.headers = headers
        self.bodyContains = bodyContains
    }

    /// Check if a request matches this rule
    func matches(_ request: NetworkRequest) -> Bool {
        // Check full URL (Mandatory)
        if let fullURL = fullURL, !fullURL.isEmpty {
            if request.url != fullURL {
                return false
            }
        } else {
            // If fullURL is missing, we can't match strictly as requested
            return false
        }

        // Check method
        if let method = method, request.method != method {
            return false
        }

        // Check query parameters
        for param in queryParameters {
            let found = request.queryParameters.contains { $0.key == param.key && $0.value == param.value }
            if !found { return false }
        }

        // Check headers
        for header in headers {
            let found = request.requestHeaders.contains { $0.key == header.key && $0.value == header.value }
            if !found { return false }
        }

        // Check body contains
        if let bodyContains = bodyContains, !bodyContains.isEmpty {
            guard let bodyString = request.requestBody?.rawString else { return false }
            if !bodyString.contains(bodyContains) { return false }
        }

        return true
    }
}

// MARK: - Stub Response

public struct StubResponse: Codable, Identifiable {
    public let id: UUID
    var statusCode: Int
    var headers: [RequestHeader]
    var jsonBody: String?
    var plainTextBody: String?
    var responseDelay: TimeInterval
    var errorType: StubErrorType

    init(
        id: UUID = UUID(),
        statusCode: Int = 200,
        headers: [RequestHeader] = [
            RequestHeader(key: "Content-Type", value: "application/json")
        ],
        jsonBody: String? = nil,
        plainTextBody: String? = nil,
        responseDelay: TimeInterval = 0,
        errorType: StubErrorType = .none
    ) {
        self.id = id
        self.statusCode = statusCode
        self.headers = headers
        self.jsonBody = jsonBody
        self.plainTextBody = plainTextBody
        self.responseDelay = responseDelay
        self.errorType = errorType
    }

    var bodyContent: String {
        jsonBody ?? plainTextBody ?? ""
    }

    var isJSONValid: Bool {
        guard let json = jsonBody, !json.isEmpty else { return true }
        guard let data = json.data(using: .utf8) else { return false }
        return (try? JSONSerialization.jsonObject(with: data)) != nil
    }
}

// MARK: - Stub Scenario

public struct StubScenario: Identifiable, Codable {
    public let id: UUID
    public var name: String
    public var description: String
    var response: StubResponse
    var isActive: Bool

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        response: StubResponse = StubResponse(),
        isActive: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.response = response
        self.isActive = isActive
    }
}

// MARK: - Request Stub

public struct RequestStub: Identifiable, Codable {
    public let id: UUID
    public var name: String
    public var description: String
    public var matchRule: StubMatchRule
    public var scenarios: [StubScenario]
    public var isEnabled: Bool
    public var usageCount: Int
    public var lastTriggered: Date?
    public var createdAt: Date
    public var updatedAt: Date
    public var groupName: String?

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        matchRule: StubMatchRule = StubMatchRule(),
        scenarios: [StubScenario] = [],
        isEnabled: Bool = true,
        usageCount: Int = 0,
        lastTriggered: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        groupName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.matchRule = matchRule
        self.scenarios = scenarios
        self.isEnabled = isEnabled
        self.usageCount = usageCount
        self.lastTriggered = lastTriggered
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.groupName = groupName
    }

    var activeScenario: StubScenario? {
        scenarios.first { $0.isActive }
    }

    var methodDisplay: String {
        matchRule.method?.rawValue ?? "ANY"
    }

    var pathDisplay: String {
        matchRule.urlPath ?? matchRule.fullURL ?? "—"
    }
}
