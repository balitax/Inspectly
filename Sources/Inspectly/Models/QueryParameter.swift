//
//  QueryParameter.swift
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

// MARK: - Query Parameter

public struct QueryParameter: Identifiable, Codable, Hashable {
    public let id: UUID
    var key: String
    var value: String

    init(id: UUID = UUID(), key: String, value: String) {
        self.id = id
        self.key = key
        self.value = value
    }
}

extension QueryParameter {
    /// Parse query parameters from a URL string
    static func parse(from urlString: String) -> [QueryParameter] {
        guard let components = URLComponents(string: urlString),
              let queryItems = components.queryItems else {
            return []
        }
        return queryItems.map {
            QueryParameter(key: $0.name, value: $0.value ?? "")
        }
    }
}
