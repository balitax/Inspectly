//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation

// MARK: - Request Body

struct RequestBody: Codable {
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

struct ResponseBody: Codable {
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
