//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
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

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        modifier(ShakeDetector(action: action))
    }
}
