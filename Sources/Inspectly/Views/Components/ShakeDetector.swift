//
//  ShakeDetector.swift
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

import SwiftUI
import UIKit

// MARK: - Shake Detector

/// Detects device shake gestures to trigger Inspectly overlay.
/// Uses UIKit bridging since SwiftUI doesn't natively support shake detection.
///
/// Usage:
/// ```swift
/// .onShake {
///     showInspectly = true
/// }
/// ```

// MARK: - Notification Extension

extension UIDevice {
    static let deviceDidShake = Notification.Name("deviceDidShake")
}

// MARK: - Shake Manager

final class ShakeManager {
    static let shared = ShakeManager()
    var onShake: (() -> Void)?
    
    private init() {}
    
    func trigger() {
        DispatchQueue.main.async {
            self.onShake?()
        }
    }
}

// MARK: - UIWindow Extension for Shake

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            ShakeManager.shared.trigger()
        }
    }
}

// MARK: - Shake View Modifier

@available(iOS 16.0, *)
struct ShakeDetector: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShake)) { _ in
                action()
            }
    }
}

// MARK: - View Extension

@available(iOS 16.0, *)
extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        modifier(ShakeDetector(action: action))
    }
}
