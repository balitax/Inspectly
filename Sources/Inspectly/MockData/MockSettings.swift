//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
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
