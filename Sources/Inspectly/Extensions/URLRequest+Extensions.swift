//
//  URLRequest+Extensions.swift
//  Inspectly
//
//  Created by Agus Cahyono on 19/04/2026.
//  Copyright © 2026 Agus Cahyono. All rights reserved.
//

import Foundation

extension URLRequest {
    
    /// Safely extracts the body data from the request, handling both `httpBody` and `httpBodyStream`.
    /// Note: If reading from `httpBodyStream`, the stream will be consumed and replaced with a new one.
    mutating func extractBodyData() -> Data? {
        if let body = httpBody {
            return body
        }
        
        guard let stream = httpBodyStream else {
            return nil
        }
        
        let data = Data(reading: stream)
        // After reading the stream, set it as httpBody and clear the stream
        // This is generally more compatible with URLSession when the data is in memory.
        httpBody = data
        httpBodyStream = nil
        return data
    }
    
    /// Returns the content type of the request based on the Content-Type header.
    var contentType: ContentType {
        let header = value(forHTTPHeaderField: "Content-Type")?.lowercased() ?? ""
        return ContentType.parse(header)
    }
}

extension HTTPURLResponse {
    /// Returns the content type of the response based on the Content-Type header.
    var contentType: ContentType {
        let header = (allHeaderFields["Content-Type"] as? String)?.lowercased() ?? ""
        return ContentType.parse(header)
    }
}

extension ContentType {
    static func parse(_ header: String) -> ContentType {
        if header.contains("application/json") { return .json }
        if header.contains("application/xml") || header.contains("text/xml") { return .xml }
        if header.contains("application/x-www-form-urlencoded") { return .formURLEncoded }
        if header.contains("multipart/form-data") { return .multipartFormData }
        if header.contains("text/plain") { return .plainText }
        if header.contains("text/html") { return .html }
        if header.contains("application/graphql") { return .graphql }
        if header.contains("application/octet-stream") { return .octetStream }
        return .unknown
    }
    
    /// Detects content type from body data when headers are misleading or missing.
    static func sniff(data: Data) -> ContentType? {
        guard !data.isEmpty else { return nil }
        
        // Convert a small portion of data to string for sniffing
        let sniffSize = min(data.count, 512)
        let sniffData = data.prefix(sniffSize)
        guard let content = String(data: sniffData, encoding: .utf8)?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }
        
        if content.hasPrefix("<!doctype html") || content.hasPrefix("<html") {
            return .html
        }
        
        if content.hasPrefix("{") || content.hasPrefix("[") {
            return .json
        }
        
        if content.hasPrefix("<?xml") || content.hasPrefix("<") {
            // Check if it's actually HTML but missing the doctype
            if content.contains("<body") || content.contains("<head") || content.contains("<title") {
                return .html
            }
            return .xml
        }
        
        return nil
    }
}

extension Data {
    /// Initialize Data by reading from an InputStream.
    init(reading stream: InputStream) {
        self.init()
        stream.open()
        
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        
        while stream.hasBytesAvailable {
            let read = stream.read(buffer, maxLength: bufferSize)
            if read > 0 {
                self.append(buffer, count: read)
            } else if read < 0 {
                break
            }
        }
        
        buffer.deallocate()
        stream.close()
    }
}
