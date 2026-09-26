//
//  NotificationDelegate.swift
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

// MARK: - Notification Delegate

/// Handles presentation of notifications while the app is in the foreground
/// and routes tap actions back into the Inspectly UI.
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    private override init() {
        super.init()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let requestIDString = userInfo["requestID"] as? String,
           let requestID = UUID(uuidString: requestIDString) {
            NotificationCenter.default.post(
                name: .inspectlyNotificationTapped,
                object: requestID
            )
        }
        completionHandler()
    }
}
