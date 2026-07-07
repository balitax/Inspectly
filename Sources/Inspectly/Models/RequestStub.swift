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

// MARK: - URL Match Mode

public enum URLMatchMode: String, Codable, CaseIterable, Identifiable {
    case exact    = "Exact"
    case contains = "Contains"
    case prefix   = "Prefix"
    case suffix   = "Suffix"
    case regex    = "Regex"

    public var id: String { rawValue }

    var iconName: String {
        switch self {
        case .exact:    return "equal.circle"
        case .contains: return "text.magnifyingglass"
        case .prefix:   return "arrow.right.to.line"
        case .suffix:   return "arrow.left.to.line"
        case .regex:    return "chevron.left.forwardslash.chevron.right"
        }
    }

    var hint: String {
        switch self {
        case .exact:    return "https://api.example.com/v1/users"
        case .contains: return "/v1/users"
        case .prefix:   return "https://api.example.com"
        case .suffix:   return "/users"
        case .regex:    return "api\\.example\\.com/v\\d+/users"
        }
    }
}

// MARK: - Stub Match Rule

public struct StubMatchRule: Codable, Identifiable {
    public let id: UUID
    var method: HTTPMethodType?
    var urlPattern: String?
    var urlMatchMode: URLMatchMode
    var queryParameters: [QueryParameter]
    var headers: [RequestHeader]
    var bodyContains: String?

    // Legacy field — mapped from old `fullURL` / `urlPath` on decode
    var urlPath: String? {
        get { urlMatchMode == .exact ? nil : urlPattern }
        set { urlPattern = newValue }
    }
    var fullURL: String? {
        get { urlMatchMode == .exact ? urlPattern : nil }
        set { urlPattern = newValue }
    }

    init(
        id: UUID = UUID(),
        method: HTTPMethodType? = nil,
        urlPath: String? = nil,
        fullURL: String? = nil,
        urlMatchMode: URLMatchMode = .exact,
        queryParameters: [QueryParameter] = [],
        headers: [RequestHeader] = [],
        bodyContains: String? = nil
    ) {
        self.id = id
        self.method = method
        self.urlPattern = fullURL ?? urlPath
        self.urlMatchMode = urlMatchMode
        self.queryParameters = queryParameters
        self.headers = headers
        self.bodyContains = bodyContains
    }

    // MARK: - Codable with legacy support

    private enum CodingKeys: String, CodingKey {
        case id, method, urlPattern, urlMatchMode, queryParameters, headers, bodyContains
        case legacyFullURL = "fullURL"
        case legacyURLPath = "urlPath"
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id             = try c.decode(UUID.self, forKey: .id)
        method         = try c.decodeIfPresent(HTTPMethodType.self, forKey: .method)
        urlMatchMode   = try c.decodeIfPresent(URLMatchMode.self, forKey: .urlMatchMode) ?? .exact
        queryParameters = try c.decodeIfPresent([QueryParameter].self, forKey: .queryParameters) ?? []
        headers        = try c.decodeIfPresent([RequestHeader].self, forKey: .headers) ?? []
        bodyContains   = try c.decodeIfPresent(String.self, forKey: .bodyContains)
        // Prefer new field; fall back to legacy fullURL / urlPath
        urlPattern     = try c.decodeIfPresent(String.self, forKey: .urlPattern)
            ?? c.decodeIfPresent(String.self, forKey: .legacyFullURL)
            ?? c.decodeIfPresent(String.self, forKey: .legacyURLPath)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,              forKey: .id)
        try c.encodeIfPresent(method, forKey: .method)
        try c.encode(urlPattern,      forKey: .urlPattern)
        try c.encode(urlMatchMode,    forKey: .urlMatchMode)
        try c.encode(queryParameters, forKey: .queryParameters)
        try c.encode(headers,         forKey: .headers)
        try c.encodeIfPresent(bodyContains, forKey: .bodyContains)
    }

    /// Check if a request matches this rule
    func matches(_ request: NetworkRequest) -> Bool {
        // URL pattern match
        if let pattern = urlPattern, !pattern.isEmpty {
            if !urlMatches(request.url, pattern: pattern, mode: urlMatchMode) {
                return false
            }
        } else {
            return false  // no pattern = no match
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

        // Check headers — header names are case-insensitive per RFC 7230
        for header in headers {
            let found = request.requestHeaders.contains {
                $0.key.lowercased() == header.key.lowercased() && $0.value == header.value
            }
            if !found { return false }
        }

        // Check body contains
        if let bodyContains = bodyContains, !bodyContains.isEmpty {
            guard let bodyString = request.requestBody?.rawString else { return false }
            if !bodyString.contains(bodyContains) { return false }
        }

        return true
    }

    /// Match a URL against a pattern using the specified mode.
    private func urlMatches(_ url: String, pattern: String, mode: URLMatchMode) -> Bool {
        switch mode {
        case .exact:
            return urlsExactMatch(url, pattern)
        case .contains:
            return url.contains(pattern)
        case .prefix:
            return url.hasPrefix(pattern)
        case .suffix:
            return url.hasSuffix(pattern)
        case .regex:
            guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
            let range = NSRange(url.startIndex..., in: url)
            return regex.firstMatch(in: url, range: range) != nil
        }
    }

    /// RFC 3986 exact URL comparison: scheme+host case-insensitive, path+query case-sensitive.
    private func urlsExactMatch(_ lhs: String, _ rhs: String) -> Bool {
        guard let l = URLComponents(string: lhs),
              let r = URLComponents(string: rhs) else { return lhs == rhs }
        return l.scheme?.lowercased() == r.scheme?.lowercased()
            && l.host?.lowercased()   == r.host?.lowercased()
            && l.port                 == r.port
            && l.path                 == r.path
            && l.query                == r.query
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

    var contentType: ContentType {
        let header = headers.first { $0.key.lowercased() == "content-type" }?.value.lowercased() ?? ""
        return ContentType.parse(header)
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
        matchRule.urlPattern ?? "—"
    }

    /// Copy with sensitive header values (in the match rule and every scenario's mocked
    /// response) masked — use before serializing this stub for export/share, since stubs
    /// created "from a captured request" can carry a real Authorization/Cookie value.
    func maskedForExport() -> RequestStub {
        var copy = self
        copy.matchRule.headers = matchRule.headers.map(\.maskedHeader)
        copy.scenarios = scenarios.map { scenario in
            var scenario = scenario
            scenario.response.headers = scenario.response.headers.map(\.maskedHeader)
            return scenario
        }
        return copy
    }
}
