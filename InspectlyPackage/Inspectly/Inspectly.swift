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
final class Inspectly {
    
    // MARK: - Configuration
    
    struct Configuration {
        var isLoggingEnabled: Bool = true
        
        var isStubEnabled: Bool = false
        
        var ignoredHosts: Set<String> = []
        
        var isShakeGestureEnabled: Bool = true
        
        var ignoreLocalhost: Bool = true
        
        var stubRepository: (any StubRepositoryProtocol)?
        
        init(
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
    
    private static var configuration: Configuration?
    private static var isEnabled: Bool = false
    
    // MARK: - Public API
    
    /// Enable Inspectly with default configuration.
    /// This will register URLProtocol and configure Alamofire interception.
    static func enable() {
        enable(with: Configuration())
    }
    
    /// Enable Inspectly with custom configuration.
    /// - Parameter configuration: Custom configuration for Inspectly
    static func enable(with configuration: Configuration) {
        guard !isEnabled else { return }
        
        self.configuration = configuration
        
        configureURLProtocol(with: configuration)
        
        if configuration.isShakeGestureEnabled {
            ShakeManager.shared.onShake = {
                Inspectly.presentInspector()
            }
        }
        
        isEnabled = true
        
        print("[Inspectly] Enabled - shake device or press ⌘+Ctrl+Z to open inspector")
    }
    
    /// Disable Inspectly and unregister interceptors.
    static func disable() {
        URLProtocol.unregisterClass(InspectlyURLProtocol.self)
        ShakeManager.shared.onShake = nil
        isEnabled = false
        print("[Inspectly] Disabled")
    }
    
    /// Check if Inspectly is currently enabled.
    static var isActive: Bool {
        return isEnabled
    }
    
    /// Present the Inspectly UI manually.
    static func presentInspector(rootView: UIViewController? = nil) {
        guard let config = configuration else {
            print("[Inspectly] Not enabled. Call Inspectly.enable() first.")
            return
        }
        
        let container = DependencyContainer.shared
        
        if !isEnabled {
            configureURLProtocol(with: config)
        }
        
        DispatchQueue.main.async {
            let presentingVC = UIApplication.shared.windows.first?.rootViewController
            
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
    static var container: DependencyContainer {
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
    }
}