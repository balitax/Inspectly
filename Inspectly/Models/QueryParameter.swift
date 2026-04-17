//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation

// MARK: - Query Parameter

struct QueryParameter: Identifiable, Codable, Hashable {
    let id: UUID
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
