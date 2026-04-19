//
//  NetworkThrottlingPreset.swift
//  Inspectly
//
//  Created by Agus Cahyono on 18/04/2026.
//  Copyright © 2026 Agus Cahyono. All rights reserved.
//

import Foundation

// MARK: - Network Throttling

public enum NetworkThrottlingPreset: String, Codable, CaseIterable, Identifiable {
    case off
    case edge
    case threeG
    case highLatency
    case dnsFailure
    case custom

    public var id: String { rawValue }

    var displayName: String {
        switch self {
        case .off: return "Off"
        case .edge: return "Edge"
        case .threeG: return "3G"
        case .highLatency: return "High Latency"
        case .dnsFailure: return "DNS Failure"
        case .custom: return "Custom"
        }
    }

    var iconName: String {
        switch self {
        case .off: return "bolt.horizontal.circle"
        case .edge: return "antenna.radiowaves.left.and.right.slash"
        case .threeG: return "antenna.radiowaves.left.and.right"
        case .highLatency: return "clock.badge.exclamationmark"
        case .dnsFailure: return "wifi.exclamationmark"
        case .custom: return "slider.horizontal.3"
        }
    }

    var description: String {
        switch self {
        case .off:
            return "Uses the normal network path without extra delay or failure injection."
        case .edge:
            return "Adds noticeable latency and a low transfer rate to mimic older cellular networks."
        case .threeG:
            return "Adds moderate latency with reduced bandwidth for slower mobile conditions."
        case .highLatency:
            return "Adds a long startup delay while keeping the transfer speed unchanged."
        case .dnsFailure:
            return "Fails requests before they reach the server to simulate host resolution issues."
        case .custom:
            return "Manually define latency and bandwidth limits for specific testing scenarios."
        }
    }

    func configuration(customDelay: TimeInterval = 0, customBytesPerSecond: Double? = nil) -> NetworkThrottlingConfiguration {
        switch self {
        case .off:
            return NetworkThrottlingConfiguration()
        case .edge:
            return NetworkThrottlingConfiguration(
                requestDelay: 0.45,
                bytesPerSecond: 32_000
            )
        case .threeG:
            return NetworkThrottlingConfiguration(
                requestDelay: 0.18,
                bytesPerSecond: 220_000
            )
        case .highLatency:
            return NetworkThrottlingConfiguration(
                requestDelay: 1.5,
                bytesPerSecond: nil
            )
        case .dnsFailure:
            return NetworkThrottlingConfiguration(
                requestDelay: 0.15,
                failureMode: .dnsFailure
            )
        case .custom:
            return NetworkThrottlingConfiguration(
                requestDelay: customDelay,
                bytesPerSecond: customBytesPerSecond
            )
        }
    }

    @available(*, deprecated, message: "Use configuration(customDelay:customBytesPerSecond:) instead")
    var configuration: NetworkThrottlingConfiguration {
        configuration()
    }
}

struct NetworkThrottlingConfiguration {
    enum FailureMode {
        case dnsFailure
    }

    let requestDelay: TimeInterval
    let bytesPerSecond: Double?
    let failureMode: FailureMode?

    init(
        requestDelay: TimeInterval = 0,
        bytesPerSecond: Double? = nil,
        failureMode: FailureMode? = nil
    ) {
        self.requestDelay = requestDelay
        self.bytesPerSecond = bytesPerSecond
        self.failureMode = failureMode
    }
}
