//
//  NotificationManager.swift
//  Inspectly
//
//  Created by OpenCode on 26/09/2026.
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
import UserNotifications

// MARK: - Notification Manager

/// Prototype local notification manager for Inspectly alerts.
/// Triggers notifications when captured requests match configured rules:
/// slow requests, errors, or requests to specific hosts.
@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    var isEnabled: Bool = false
    var alertSlowRequests: Bool = false
    var alertErrorRequests: Bool = false
    var alertHosts: [String] = []
    var slowRequestThreshold: TimeInterval = 1.0

    private var lastAlertTimestamps: [String: Date] = [:]
    private let cooldown: TimeInterval = 10

    private init() {}

    /// Request notification authorization if any alert is enabled.
    func requestAuthorizationIfNeeded() {
        guard isEnabled else { return }

        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("[Inspectly] Notification authorization error: \(error)")
            } else {
                print("[Inspectly] Notification authorization granted: \(granted)")
            }
        }
    }

    /// Evaluate a captured request against the current alert rules and
    /// schedule a local notification if a rule matches.
    func evaluate(_ request: NetworkRequest) {
        guard isEnabled else { return }

        var reasons: [String] = []

        if alertSlowRequests,
           let duration = request.duration,
           duration >= slowRequestThreshold {
            reasons.append("Slow: \(String(format: "%.2fs", duration))")
        }

        if alertErrorRequests, request.isError {
            reasons.append("Error \(request.statusCodeDisplay)")
        }

        if !alertHosts.isEmpty {
            let requestHost = request.host.lowercased()
            if alertHosts.contains(where: { $0.lowercased() == requestHost }) {
                reasons.append("Host: \(request.host)")
            }
        }

        guard !reasons.isEmpty else { return }

        let key = "\(request.host)-\(request.method.rawValue)-\(reasons.joined(separator: "-"))"
        if let last = lastAlertTimestamps[key],
           Date().timeIntervalSince(last) < cooldown {
            return
        }
        lastAlertTimestamps[key] = Date()

        schedule(
            title: "Inspectly Alert",
            body: "\(request.method.rawValue) \(request.shortURL) · \(reasons.joined(separator: " · "))",
            requestID: request.id
        )
    }

    private func schedule(title: String, body: String, requestID: UUID) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = ["requestID": requestID.uuidString]

        let notificationRequest = UNNotificationRequest(
            identifier: requestID.uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(notificationRequest) { error in
            if let error = error {
                print("[Inspectly] Failed to schedule notification: \(error)")
            }
        }
    }
}
