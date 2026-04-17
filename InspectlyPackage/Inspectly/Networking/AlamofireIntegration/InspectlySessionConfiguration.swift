//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation

// MARK: - Inspectly Session Configuration for Alamofire
///
/// Helper to configure an Alamofire Session with Inspectly monitoring and stubbing.
///
/// ## Quick Start
///
/// ```swift
/// import Alamofire
///
/// // Option 1: Full integration (monitoring + stubbing)
/// let session = InspectlySessionConfiguration.configuredSession(
///     container: DependencyContainer.shared
/// )
///
/// // Option 2: Monitoring only (no stubbing)
/// let session = InspectlySessionConfiguration.monitoringSession(
///     container: DependencyContainer.shared
/// )
///
/// // Option 3: Add to existing configuration
/// let config = URLSessionConfiguration.default
/// InspectlySessionConfiguration.addProtocol(to: config)
/// ```
///
/// ## Architecture
///
/// ```
/// ┌─────────────────────────────────────────┐
/// │              Alamofire Session           │
/// │                                         │
/// │  ┌──────────────────────────────────┐   │
/// │  │    InspectlyRequestInterceptor   │   │
/// │  │    (Request Adaptation & Stub    │   │
/// │  │     Matching)                    │   │
/// │  └──────────┬───────────────────────┘   │
/// │             │                           │
/// │  ┌──────────▼───────────────────────┐   │
/// │  │    InspectlyEventMonitor         │   │
/// │  │    (Request/Response Logging)    │   │
/// │  └──────────┬───────────────────────┘   │
/// │             │                           │
/// │  ┌──────────▼───────────────────────┐   │
/// │  │    InspectlyURLProtocol          │   │
/// │  │    (Low-level Interception)      │   │
/// │  └──────────────────────────────────┘   │
/// └─────────────────────────────────────────┘
///         │
///         ▼
/// ┌─────────────────────────────────────────┐
/// │           StubEngine                    │
/// │  (Matches requests to stubs)            │
/// └──────────┬──────────────────────────────┘
///            │
///            ▼
/// ┌─────────────────────────────────────────┐
/// │       StubRepository                    │
/// │  (Stores and manages stubs)             │
/// └─────────────────────────────────────────┘
/// ```

struct InspectlySessionConfiguration {

    /// Create a fully configured session with monitoring and stubbing.
    ///
    /// - Parameter container: The dependency container with configured services.
    /// - Returns: A description of how to create the session (since we can't import Alamofire directly).
    static func configuredSessionDescription(container: DependencyContainer) -> String {
        """
        // In your networking layer:
        import Alamofire

        let monitor = InspectlyEventMonitor(
            requestRepository: container.requestRepository
        )

        let stubEngine = StubEngine(
            stubRepository: container.stubRepository
        )

        let interceptor = InspectlyRequestInterceptor(
            stubEngine: stubEngine
        )

        // Create Alamofire Session with Inspectly integration
        let session = Session(
            configuration: {
                let config = URLSessionConfiguration.af.default
                // Optional: Add URLProtocol for deeper interception
                config.protocolClasses = [InspectlyURLProtocol.self] + (config.protocolClasses ?? [])
                return config
            }(),
            interceptor: interceptor,
            eventMonitors: [monitor] + Session.default.eventMonitors
        )
        """
    }

    /// Add InspectlyURLProtocol to a URLSessionConfiguration.
    static func addProtocol(to configuration: inout URLSessionConfiguration) {
        var protocols = configuration.protocolClasses ?? []
        protocols.insert(InspectlyURLProtocol.self, at: 0)
        configuration.protocolClasses = protocols
    }

    /// Configure InspectlyURLProtocol with the given dependency container.
    static func configureURLProtocol(with container: DependencyContainer) {
        InspectlyURLProtocol.stubRepository = container.stubRepository
        InspectlyURLProtocol.onRequestCaptured = { request in
            Task {
                await container.requestRepository.addRequest(request)
            }
        }
    }
}
