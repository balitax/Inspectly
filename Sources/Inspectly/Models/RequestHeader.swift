//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
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
