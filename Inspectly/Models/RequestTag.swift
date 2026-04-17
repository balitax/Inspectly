//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation

// MARK: - Request Tag

struct RequestTag: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var color: String // Semantic color name

    init(id: UUID = UUID(), name: String, color: String = "tagDefault") {
        self.id = id
        self.name = name
        self.color = color
    }
}

// MARK: - Predefined Tags

extension RequestTag {
    static let auth = RequestTag(name: "Auth", color: "tagAuth")
    static let api = RequestTag(name: "API", color: "tagAPI")
    static let upload = RequestTag(name: "Upload", color: "tagUpload")
    static let download = RequestTag(name: "Download", color: "tagDownload")
    static let graphQL = RequestTag(name: "GraphQL", color: "tagGraphQL")
    static let websocket = RequestTag(name: "WebSocket", color: "tagWebSocket")
    static let critical = RequestTag(name: "Critical", color: "tagCritical")
    static let debug = RequestTag(name: "Debug", color: "tagDebug")

    static let allPredefined: [RequestTag] = [
        .auth, .api, .upload, .download, .graphQL, .websocket, .critical, .debug
    ]
}
