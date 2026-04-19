//
//  RequestTag.swift
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

// MARK: - Request Tag

public struct RequestTag: Identifiable, Codable, Hashable {
    public let id: UUID
    public var name: String
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
