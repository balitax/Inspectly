//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation

// MARK: - App Settings

struct AppSettings: Codable {
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
        areStubsEnabled: Bool = false,
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

struct IgnoredHost: Identifiable, Codable, Hashable {
    let id: UUID
    var host: String
    var isEnabled: Bool

    init(id: UUID = UUID(), host: String, isEnabled: Bool = true) {
        self.id = id
        self.host = host
        self.isEnabled = isEnabled
    }
}
