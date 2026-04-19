//
//  RequestBody.swift
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

// MARK: - Request Body

public struct RequestBody: Codable {
    var rawString: String?
    var rawData: Data?
    var contentType: ContentType
    var size: Int64

    init(
        rawString: String? = nil,
        rawData: Data? = nil,
        contentType: ContentType = .json,
        size: Int64 = 0
    ) {
        self.rawString = rawString
        self.rawData = rawData
        self.contentType = contentType
        self.size = size
    }

    var prettyPrinted: String {
        guard let raw = rawString else { return "" }
        if contentType == .json {
            return raw.prettyPrintedJSON ?? raw
        }
        return raw
    }

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }

    var isEmpty: Bool {
        (rawString?.isEmpty ?? true) && (rawData?.isEmpty ?? true)
    }
}

// MARK: - Response Body

public struct ResponseBody: Codable {
    var rawString: String?
    var rawData: Data?
    var contentType: ContentType
    var size: Int64

    init(
        rawString: String? = nil,
        rawData: Data? = nil,
        contentType: ContentType = .json,
        size: Int64 = 0
    ) {
        self.rawString = rawString
        self.rawData = rawData
        self.contentType = contentType
        self.size = size
    }

    var prettyPrinted: String {
        guard let raw = rawString else { return "" }
        if contentType == .json {
            return raw.prettyPrintedJSON ?? raw
        }
        return raw
    }

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }

    var isEmpty: Bool {
        (rawString?.isEmpty ?? true) && (rawData?.isEmpty ?? true)
    }
}
