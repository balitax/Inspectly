//
//  SecurityScanner.swift
//  Inspectly
//
//  Created by OpenCode on 27/09/2026.
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

// MARK: - Security Scanner

/// Rule-based security scanner for captured network requests.
enum SecurityScanner {
    static let securityHeaders = [
        "Strict-Transport-Security",
        "X-Content-Type-Options",
        "X-Frame-Options",
        "Content-Security-Policy"
    ]

    static let sensitiveHeaderKeys: Set<String> = [
        "authorization",
        "x-api-key",
        "api-key",
        "apikey",
        "x-auth-token",
        "x-access-token",
        "x-secret",
        "cookie"
    ]

    static let sensitiveQueryKeys: Set<String> = [
        "password",
        "token",
        "secret",
        "api_key",
        "apikey",
        "api-key",
        "auth"
    ]

    static let secretPatterns: [String] = [
        "[a-zA-Z0-9_-]{20,}",
        "[A-Za-z0-9]{32,}",
        "[A-Za-z0-9]{40,}",
        "[A-Za-z0-9]{64,}"
    ]

    /// Scan a captured request/response and return any security issues found.
    static func scan(_ request: NetworkRequest) -> [SecurityIssue] {
        var issues: [SecurityIssue] = []

        if let scheme = URL(string: request.url)?.scheme?.lowercased(), scheme == "http" {
            issues.append(SecurityIssue(
                requestID: request.id,
                timestamp: request.timestamp,
                severity: .critical,
                category: .unencryptedHTTP,
                title: "Unencrypted HTTP Request",
                description: "Request sent over HTTP without TLS: \(request.url)"
            ))
        }

        let responseHeaderKeys = Set(request.responseHeaders.map { $0.key.lowercased() })
        for header in securityHeaders {
            if !responseHeaderKeys.contains(header.lowercased()) {
                issues.append(SecurityIssue(
                    requestID: request.id,
                    timestamp: request.timestamp,
                    severity: .low,
                    category: .missingSecurityHeader,
                    title: "Missing \(header)",
                    description: "Response does not include the \(header) security header."
                ))
            }
        }

        for header in request.requestHeaders {
            let lowerKey = header.key.lowercased()
            if sensitiveHeaderKeys.contains(lowerKey) {
                let masked = maskIfLong(header.value)
                issues.append(SecurityIssue(
                    requestID: request.id,
                    timestamp: request.timestamp,
                    severity: .high,
                    category: .exposedSecret,
                    title: "Exposed \(header.key)",
                    description: "Sensitive header sent: \(header.key) = \(masked)"
                ))
            }
        }

        for param in request.queryParameters {
            if sensitiveQueryKeys.contains(param.key.lowercased()) {
                issues.append(SecurityIssue(
                    requestID: request.id,
                    timestamp: request.timestamp,
                    severity: .critical,
                    category: .sensitiveInQuery,
                    title: "Sensitive Query Parameter: \(param.key)",
                    description: "The key '\(param.key)' appears in the URL query string."
                ))
            }
        }

        let searchableText = [
            request.url,
            request.requestBody?.rawString ?? ""
        ].joined(separator: " ")

        if let match = detectExposedSecret(in: searchableText) {
            issues.append(SecurityIssue(
                requestID: request.id,
                timestamp: request.timestamp,
                severity: .high,
                category: .exposedSecret,
                title: "Potential Secret in Request",
                description: "Detected possible API key/token: \(match)"
            ))
        }

        return issues
    }

    // MARK: - Helpers

    private static func maskIfLong(_ value: String) -> String {
        guard value.count > 8 else { return value }
        let prefix = String(value.prefix(4))
        return prefix + String(repeating: "•", count: 8)
    }

    private static func detectExposedSecret(in text: String) -> String? {
        let lower = text.lowercased()
        let markers = ["bearer", "token", "apikey", "api_key", "api-key", "secret", "password"]
        guard markers.contains(where: { lower.contains($0) }) else { return nil }

        for pattern in secretPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)) {
                let matched = (text as NSString).substring(with: match.range)
                if matched.count >= 20 {
                    return String(matched.prefix(8)) + "••••"
                }
            }
        }
        return nil
    }
}
