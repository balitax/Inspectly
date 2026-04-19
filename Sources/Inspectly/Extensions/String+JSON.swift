//
//  String+JSON.swift
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

extension String {
    /// Pretty print JSON string
    public var prettyPrintedJSON: String? {
        guard let data = self.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data),
              let prettyData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys]),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return nil
        }
        return prettyString
    }

    /// Validate if string is valid JSON
    public var isValidJSON: Bool {
        guard let data = self.data(using: .utf8) else { return false }
        return (try? JSONSerialization.jsonObject(with: data)) != nil
    }

    /// Minify JSON string
    var minifiedJSON: String? {
        guard let data = self.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data),
              let minData = try? JSONSerialization.data(withJSONObject: json, options: []),
              let minString = String(data: minData, encoding: .utf8) else {
            return nil
        }
        return minString
    }

    /// Truncate string to a given length
    func truncated(to length: Int, trailing: String = "…") -> String {
        if count <= length { return self }
        return String(prefix(length)) + trailing
    }

    /// Extract host from URL string
    var urlHost: String? {
        URLComponents(string: self)?.host
    }

    /// Extract path from URL string
    var urlPath: String? {
        URLComponents(string: self)?.path
    }

    /// Convert to base64
    var base64Encoded: String? {
        data(using: .utf8)?.base64EncodedString()
    }

    /// Decode from base64
    var base64Decoded: String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
