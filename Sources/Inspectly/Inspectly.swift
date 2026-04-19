//
//  Inspectly.swift
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
        
        public var isStubEnabled: Bool = true

        public var networkThrottlingPreset: NetworkThrottlingPreset = .off
        
        public var ignoredHosts: Set<String> = []
        
        /// Enable shake gesture to open inspector
        public var isShakeGestureEnabled: Bool = true
        
        public var ignoreLocalhost: Bool = true
        
        public var stubRepository: (any StubRepositoryProtocol)?
        
        public init(
            isLoggingEnabled: Bool = true,
            isStubEnabled: Bool = true,
            networkThrottlingPreset: NetworkThrottlingPreset = .off,
            ignoredHosts: Set<String> = [],
            isShakeGestureEnabled: Bool = true,
            ignoreLocalhost: Bool = true,
            stubRepository: (any StubRepositoryProtocol)? = nil
        ) {
            self.isLoggingEnabled = isLoggingEnabled
            self.isStubEnabled = isStubEnabled
            self.networkThrottlingPreset = networkThrottlingPreset
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
        applyShakeGesture(isEnabled: configuration.isShakeGestureEnabled)
        loadPersistedSettingsIfNeeded()
        
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
        if #available(iOS 16.0, *) {
            presentInspectorInternal(rootView: rootView)
        } else {
            print("[Inspectly] Warning: Inspectly UI requires iOS 16.0 or newer.")
        }
    }
    
    @available(iOS 16.0, *)
    private static func presentInspectorInternal(rootView: UIViewController? = nil) {
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
        InspectlyURLProtocol.networkThrottlingPreset = configuration.networkThrottlingPreset
        
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

    static func applyRuntimeSettings(_ settings: AppSettings) {
        guard let configuration else { return }

        InspectlyURLProtocol.isLoggingEnabled = settings.isLoggingEnabled
        InspectlyURLProtocol.isStubEnabled = settings.areStubsEnabled
        InspectlyURLProtocol.networkThrottlingPreset = settings.networkThrottlingPreset

        var ignoredHosts = configuration.ignoredHosts
        ignoredHosts.formUnion(settings.ignoredHosts.filter(\.isEnabled).map(\.host))

        if configuration.ignoreLocalhost {
            ignoredHosts.insert("localhost")
            ignoredHosts.insert("127.0.0.1")
        }

        InspectlyURLProtocol.ignoredHosts = ignoredHosts
        applyShakeGesture(isEnabled: settings.isShakeGestureEnabled)
    }

    private static func loadPersistedSettingsIfNeeded() {
        Task {
            do {
                if let settings = try await DependencyContainer.shared.storageManager.load(AppSettings.self, forKey: "inspectly_settings") {
                    applyRuntimeSettings(settings)
                }
            } catch {
                print("[Inspectly] Failed to load persisted settings: \(error)")
            }
        }
    }

    private static func applyShakeGesture(isEnabled: Bool) {
        if isEnabled {
            ShakeManager.shared.onShake = {
                Inspectly.presentInspector()
            }
        } else {
            ShakeManager.shared.onShake = nil
        }
    }
}
