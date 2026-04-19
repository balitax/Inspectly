//
//  RequestHeader.swift
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

// MARK: - Request Header

public struct RequestHeader: Identifiable, Codable, Hashable {
    public let id: UUID
    var key: String
    var value: String

    init(id: UUID = UUID(), key: String, value: String) {
        self.id = id
        self.key = key
        self.value = value
    }
}

// MARK: - Common Headers

extension RequestHeader {
    static let commonRequestHeaders: [String] = [
        "Accept",
        "Accept-Encoding",
        "Accept-Language",
        "Authorization",
        "Cache-Control",
        "Content-Type",
        "Content-Length",
        "Cookie",
        "Host",
        "Origin",
        "Referer",
        "User-Agent",
        "X-Request-ID",
        "X-API-Key"
    ]

    static let commonResponseHeaders: [String] = [
        "Content-Type",
        "Content-Length",
        "Content-Encoding",
        "Cache-Control",
        "Date",
        "ETag",
        "Server",
        "Set-Cookie",
        "X-Request-ID",
        "X-RateLimit-Limit",
        "X-RateLimit-Remaining"
    ]
}
