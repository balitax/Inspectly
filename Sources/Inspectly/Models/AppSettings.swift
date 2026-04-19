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
    var networkThrottlingPreset: NetworkThrottlingPreset
    var customNetworkDelay: TimeInterval
    var customNetworkBandwidth: Double?
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
        networkThrottlingPreset: NetworkThrottlingPreset = .off,
        customNetworkDelay: TimeInterval = 0,
        customNetworkBandwidth: Double? = nil,
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
        self.networkThrottlingPreset = networkThrottlingPreset
        self.customNetworkDelay = customNetworkDelay
        self.customNetworkBandwidth = customNetworkBandwidth
        self.ignoredHosts = ignoredHosts
        self.maxStoredRequests = maxStoredRequests
        self.isShakeGestureEnabled = isShakeGestureEnabled
        self.isDarkModeOverride = isDarkModeOverride
        self.isAutoResponsePrettifying = isAutoResponsePrettifying
        self.isRequestBodyTruncation = isRequestBodyTruncation
        self.truncationLimit = truncationLimit
    }

    static let `default` = AppSettings()

    enum CodingKeys: String, CodingKey {
        case isLoggingEnabled
        case areStubsEnabled
        case networkThrottlingPreset
        case customNetworkDelay
        case customNetworkBandwidth
        case ignoredHosts
        case maxStoredRequests
        case isShakeGestureEnabled
        case isDarkModeOverride
        case isAutoResponsePrettifying
        case isRequestBodyTruncation
        case truncationLimit
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        isLoggingEnabled = try container.decodeIfPresent(Bool.self, forKey: .isLoggingEnabled) ?? true
        areStubsEnabled = try container.decodeIfPresent(Bool.self, forKey: .areStubsEnabled) ?? true
        networkThrottlingPreset = try container.decodeIfPresent(NetworkThrottlingPreset.self, forKey: .networkThrottlingPreset) ?? .off
        customNetworkDelay = try container.decodeIfPresent(TimeInterval.self, forKey: .customNetworkDelay) ?? 0
        customNetworkBandwidth = try container.decodeIfPresent(Double.self, forKey: .customNetworkBandwidth)
        ignoredHosts = try container.decodeIfPresent([IgnoredHost].self, forKey: .ignoredHosts) ?? []
        maxStoredRequests = try container.decodeIfPresent(Int.self, forKey: .maxStoredRequests) ?? 500
        isShakeGestureEnabled = try container.decodeIfPresent(Bool.self, forKey: .isShakeGestureEnabled) ?? true
        isDarkModeOverride = try container.decodeIfPresent(Bool.self, forKey: .isDarkModeOverride)
        isAutoResponsePrettifying = try container.decodeIfPresent(Bool.self, forKey: .isAutoResponsePrettifying) ?? true
        isRequestBodyTruncation = try container.decodeIfPresent(Bool.self, forKey: .isRequestBodyTruncation) ?? false
        truncationLimit = try container.decodeIfPresent(Int.self, forKey: .truncationLimit) ?? 10000
    }
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
