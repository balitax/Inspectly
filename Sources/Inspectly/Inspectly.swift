//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation
import SwiftUI
import UIKit

// MARK: - Inspectly

/// Main entry point for Inspectly library.
/// Usage: Simply call `Inspectly.enable()` in your App's init.
///
/// Example:
/// ```swift
/// @main
/// struct MyApp: App {
///     init() {
///         Inspectly.enable()
///     }
///     
///     var body: some Scene {
///         WindowGroup { ContentView() }
///     }
/// }
/// ```
public final class Inspectly {
    
    // MARK: - Configuration
    
    public struct Configuration {
        public var isLoggingEnabled: Bool = true
        
        public var isStubEnabled: Bool = false
        
        public var ignoredHosts: Set<String> = []
        
        /// Enable shake gesture to open inspector
        public var isShakeGestureEnabled: Bool = true
        
        public var ignoreLocalhost: Bool = true
        
        public var stubRepository: (any StubRepositoryProtocol)?
        
        public init(
            isLoggingEnabled: Bool = true,
            isStubEnabled: Bool = false,
            ignoredHosts: Set<String> = [],
            isShakeGestureEnabled: Bool = true,
            ignoreLocalhost: Bool = true,
            stubRepository: (any StubRepositoryProtocol)? = nil
        ) {
            self.isLoggingEnabled = isLoggingEnabled
            self.isStubEnabled = isStubEnabled
            self.ignoredHosts = ignoredHosts
            self.isShakeGestureEnabled = isShakeGestureEnabled
            self.ignoreLocalhost = ignoreLocalhost
            self.stubRepository = stubRepository
        }
    }
    
    // MARK: - Properties
    
    private static var _isEnabled: Bool = false
    private static var configuration: Configuration?
    
    // MARK: - Public API
    
    /// Enable Inspectly with optional configuration.
    /// - Parameters:
    ///   - isEnabled: Enable or disable Inspectly. Use `true` for debug, `false` for production release builds.
    ///   - configuration: Custom configuration for Inspectly
    public static func enable(isEnabled: Bool = true, with configuration: Configuration = Configuration()) {
        guard !_isEnabled else { return }
        
        self.configuration = configuration
        
        guard isEnabled else {
            print("[Inspectly] Disabled via parameter")
            _isEnabled = false
            return
        }
        
        configureURLProtocol(with: configuration)
        
        // Enable shake gesture based on config
        if configuration.isShakeGestureEnabled {
            ShakeManager.shared.onShake = {
                Inspectly.presentInspector()
            }
        }
        
        _isEnabled = true
        
        print("[Inspectly] Enabled - shake device or press ⌘+Ctrl+Z to open inspector")
    }
    
    /// Disable Inspectly and unregister interceptors.
    public static func disable() {
        URLProtocol.unregisterClass(InspectlyURLProtocol.self)
        ShakeManager.shared.onShake = nil
        _isEnabled = false
        print("[Inspectly] Disabled")
    }
    
    /// Check if Inspectly is currently enabled.
    public static var isEnabled: Bool {
        return _isEnabled
    }
    
    /// Check if Inspectly is currently enabled.
    public static var isActive: Bool {
        return _isEnabled
    }
    
    /// Present the Inspectly UI manually.
    public static func presentInspector(rootView: UIViewController? = nil) {
        guard let config = configuration else {
            print("[Inspectly] Not enabled. Call Inspectly.enable() first.")
            return
        }
        
        let container = DependencyContainer.shared
        
        if !_isEnabled {
            configureURLProtocol(with: config)
        }
        
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            let presentingVC = window.rootViewController
            
            let contentView = ContentView(container: container) {
                presentingVC?.dismiss(animated: true)
            }
            let hostingController = UIHostingController(rootView: contentView)
            hostingController.modalPresentationStyle = .pageSheet
            
            if let sheet = hostingController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            
            if let root = rootView {
                root.present(hostingController, animated: true)
            } else {
                presentingVC?.present(hostingController, animated: true)
            }
        }
    }
    
    /// Get the shared container for custom access.
    public static var container: DependencyContainer {
        return DependencyContainer.shared
    }
    
    // MARK: - Private Methods
    
    private static func configureURLProtocol(with configuration: Configuration) {
        InspectlyURLProtocol.isLoggingEnabled = configuration.isLoggingEnabled
        InspectlyURLProtocol.isStubEnabled = configuration.isStubEnabled
        
        if let stubRepo = configuration.stubRepository {
            InspectlyURLProtocol.stubRepository = stubRepo
        } else {
            InspectlyURLProtocol.stubRepository = DependencyContainer.shared.stubRepository
        }
        
        var ignoredHosts = configuration.ignoredHosts
        if configuration.ignoreLocalhost {
            ignoredHosts.insert("localhost")
            ignoredHosts.insert("127.0.0.1")
        }
        InspectlyURLProtocol.ignoredHosts = ignoredHosts
        
        InspectlyURLProtocol.onRequestCaptured = { request in
            Task { @MainActor in
                await DependencyContainer.shared.requestRepository.addRequest(request)
            }
        }
        
        URLProtocol.registerClass(InspectlyURLProtocol.self)
        
        // Activate swizzling for seamless integration (Alamofire, AFNetworking, etc.)
        InspectlySwizzler.shared.activate()
    }
}
