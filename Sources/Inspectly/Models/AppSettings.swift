//
//  AppSettings.swift
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

// MARK: - App Settings

public struct AppSettings: Codable {
    var isLoggingEnabled: Bool
    var areStubsEnabled: Bool
    var ignoredHosts: [IgnoredHost]
    var maxStoredRequests: Int
    var isShakeGestureEnabled: Bool
    var isDarkModeOverride: Bool?
    var isAutoResponsePrettifying: Bool
    var isRequestBodyTruncation: Bool
    var truncationLimit: Int

    init(
        isLoggingEnabled: Bool = true,
        areStubsEnabled: Bool = true,
        ignoredHosts: [IgnoredHost] = [],
        maxStoredRequests: Int = 500,
        isShakeGestureEnabled: Bool = true,
        isDarkModeOverride: Bool? = nil,
        isAutoResponsePrettifying: Bool = true,
        isRequestBodyTruncation: Bool = false,
        truncationLimit: Int = 10000
    ) {
        self.isLoggingEnabled = isLoggingEnabled
        self.areStubsEnabled = areStubsEnabled
        self.ignoredHosts = ignoredHosts
        self.maxStoredRequests = maxStoredRequests
        self.isShakeGestureEnabled = isShakeGestureEnabled
        self.isDarkModeOverride = isDarkModeOverride
        self.isAutoResponsePrettifying = isAutoResponsePrettifying
        self.isRequestBodyTruncation = isRequestBodyTruncation
        self.truncationLimit = truncationLimit
    }

    static let `default` = AppSettings()
}

// MARK: - Ignored Host

public struct IgnoredHost: Identifiable, Codable, Hashable {
    public let id: UUID
    var host: String
    public var isEnabled: Bool

    init(id: UUID = UUID(), host: String, isEnabled: Bool = true) {
        self.id = id
        self.host = host
        self.isEnabled = isEnabled
    }
}
