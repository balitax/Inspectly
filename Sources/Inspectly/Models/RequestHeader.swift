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

// MARK: - Formatted Value

extension RequestHeader {
    /// Human-readable version of the header value.
    ///
    /// - Parses q-value notation (`br;q=1.0, gzip;q=0.9`) and sorts by priority.
    /// - Decodes encoding abbreviations to full names (`br` → `Brotli`).
    /// - Decodes language tags to locale names (`en-US` → `English (US) (en-US)`).
    var formattedValue: String {
        let hasQValues = value.contains(";q=") || value.contains("; q=")
        let normalizedKey = key.lowercased()
        let isEncodingHeader = normalizedKey == "accept-encoding" || normalizedKey == "content-encoding"
        let isLanguageHeader = normalizedKey == "accept-language"

        guard hasQValues || isEncodingHeader || isLanguageHeader else {
            return value
        }

        let entries = value
            .components(separatedBy: ",")
            .compactMap { Self.parseQValueEntry($0) }
            .sorted { $0.quality > $1.quality }

        guard !entries.isEmpty else { return value }

        return entries.map { entry in
            if isEncodingHeader { return Self.decodedEncodingName(entry.name) }
            if isLanguageHeader  { return Self.decodedLanguageName(entry.name) }
            return entry.name
        }.joined(separator: ", ")
    }

    private static func parseQValueEntry(_ raw: String) -> (name: String, quality: Double)? {
        let parts = raw.trimmingCharacters(in: .whitespaces).components(separatedBy: ";")
        let name = parts[0].trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return nil }

        var quality = 1.0
        for param in parts.dropFirst() {
            let p = param.trimmingCharacters(in: .whitespaces).lowercased()
            if p.hasPrefix("q="), let q = Double(p.dropFirst(2)) {
                quality = q
                break
            }
        }
        return (name, quality)
    }

    private static func decodedEncodingName(_ name: String) -> String {
        switch name.lowercased() {
        case "br":       return "Brotli"
        case "gzip":     return "Gzip"
        case "deflate":  return "Deflate"
        case "compress": return "Compress"
        case "zstd":     return "Zstandard"
        case "identity": return "Identity"
        case "*":        return "Any"
        default:         return name
        }
    }

    private static func decodedLanguageName(_ tag: String) -> String {
        let identifier = tag.replacingOccurrences(of: "-", with: "_")
        if let name = Locale.current.localizedString(forIdentifier: identifier), !name.isEmpty {
            return "\(name) (\(tag))"
        }
        return tag
    }
}

// MARK: - Sensitive Header Detection

extension RequestHeader {
    /// Exact lowercased header names that always contain sensitive data.
    private static let sensitiveExactKeys: Set<String> = [
        "authorization",
        "proxy-authorization",
        "cookie",
        "set-cookie",
        "x-api-key",
        "api-key",
        "apikey",
        "x-auth-token",
        "x-access-token",
        "x-secret",
        "x-csrf-token",
        "x-session-token",
        "x-auth",
    ]

    /// Substrings that, if present in the lowercased key, mark the header sensitive.
    private static let sensitiveSubstrings: [String] = [
        "token", "secret", "password", "credential", "apikey", "api_key", "api-key",
    ]

    /// Returns `true` when this header is considered sensitive and should be masked by default.
    var isSensitive: Bool {
        let lower = key.lowercased()
        if Self.sensitiveExactKeys.contains(lower) { return true }
        return Self.sensitiveSubstrings.contains { lower.contains($0) }
    }

    /// Masked representation — shows first 4 chars then bullet padding.
    /// Non-sensitive headers return `value` unchanged.
    var maskedValue: String {
        guard isSensitive, !value.isEmpty else { return value }
        let prefix = String(value.prefix(4))
        return prefix + String(repeating: "•", count: 8)
    }

    /// Copy of this header with a sensitive value replaced by `maskedValue`.
    /// Use before serializing headers for export/share so secrets aren't written unmasked.
    var maskedHeader: RequestHeader {
        RequestHeader(id: id, key: key, value: maskedValue)
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
