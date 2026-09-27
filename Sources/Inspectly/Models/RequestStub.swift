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

// MARK: - Stub Response

public struct StubResponse: Codable, Identifiable {
    public let id: UUID
    var statusCode: Int
    var headers: [RequestHeader]
    var jsonBody: String?
    var plainTextBody: String?
    var responseDelay: TimeInterval

    init(
        id: UUID = UUID(),
        statusCode: Int = 200,
        headers: [RequestHeader] = [
            RequestHeader(key: "Content-Type", value: "application/json")
        ],
        jsonBody: String? = nil,
        plainTextBody: String? = nil,
        responseDelay: TimeInterval = 0
    ) {
        self.id = id
        self.statusCode = statusCode
        self.headers = headers
        self.jsonBody = jsonBody
        self.plainTextBody = plainTextBody
        self.responseDelay = responseDelay
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
    public var method: HTTPMethodType
    public var url: String
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
        method: HTTPMethodType,
        url: String = "",
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
        self.method = method
        self.url = url
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
        method.rawValue
    }

    /// Returns true if this stub applies to the given request based on HTTP method.
    func matches(_ request: NetworkRequest) -> Bool {
        request.method == method
    }

    /// Copy with sensitive header values in every scenario's mocked response masked.
    func maskedForExport() -> RequestStub {
        var copy = self
        copy.scenarios = scenarios.map { scenario in
            var scenario = scenario
            scenario.response.headers = scenario.response.headers.map(\.maskedHeader)
            return scenario
        }
        return copy
    }

    // MARK: - Codable with legacy support

    enum CodingKeys: String, CodingKey {
        case id, name, description, method, url, scenarios, isEnabled
        case usageCount, lastTriggered, createdAt, updatedAt, groupName
        case legacyMatchRule = "matchRule"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id          = try container.decode(UUID.self, forKey: .id)
        name        = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        let legacy = try container.decodeIfPresent(LegacyMatchRule.self, forKey: .legacyMatchRule)
        method      = try container.decodeIfPresent(HTTPMethodType.self, forKey: .method)
            ?? legacy?.method
            ?? .get
        url         = try container.decodeIfPresent(String.self, forKey: .url)
            ?? legacy?.url
            ?? ""
        scenarios   = try container.decodeIfPresent([StubScenario].self, forKey: .scenarios) ?? []
        isEnabled   = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
        usageCount  = try container.decodeIfPresent(Int.self, forKey: .usageCount) ?? 0
        lastTriggered = try container.decodeIfPresent(Date.self, forKey: .lastTriggered)
        createdAt   = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        updatedAt   = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
        groupName   = try container.decodeIfPresent(String.self, forKey: .groupName)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(method, forKey: .method)
        try container.encode(url, forKey: .url)
        try container.encode(scenarios, forKey: .scenarios)
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(usageCount, forKey: .usageCount)
        try container.encodeIfPresent(lastTriggered, forKey: .lastTriggered)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(groupName, forKey: .groupName)
    }
}

// MARK: - Legacy Match Rule

private struct LegacyMatchRule: Codable {
    let method: HTTPMethodType?
    let url: String?
}
