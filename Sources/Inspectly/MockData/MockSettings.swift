//
//  MockSettings.swift
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

// MARK: - Mock Settings

struct MockSettings {
    static let `default` = AppSettings(
        isLoggingEnabled: true,
        areStubsEnabled: true,
        ignoredHosts: [
            IgnoredHost(host: "analytics.example.com", isEnabled: true),
            IgnoredHost(host: "crashlytics.google.com", isEnabled: true),
            IgnoredHost(host: "cdn.example.com", isEnabled: false)
        ],
        maxStoredRequests: 500,
        isShakeGestureEnabled: true,
        isDarkModeOverride: nil,
        isAutoResponsePrettifying: true,
        isRequestBodyTruncation: false,
        truncationLimit: 10000
    )

    static let allStubsEnabled = AppSettings(
        isLoggingEnabled: true,
        areStubsEnabled: true,
        ignoredHosts: [],
        maxStoredRequests: 1000,
        isShakeGestureEnabled: true,
        isDarkModeOverride: true,
        isAutoResponsePrettifying: true,
        isRequestBodyTruncation: true,
        truncationLimit: 5000
    )
}
