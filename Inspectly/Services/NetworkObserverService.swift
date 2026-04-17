//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation

// MARK: - Network Observer Service

/// Observes network traffic and records requests.
/// In a real app, this would be connected to URLProtocol or Alamofire EventMonitor.
final class NetworkObserverService: NetworkObserverProtocol {
    private(set) var isObserving: Bool = false
    private weak var delegate: NetworkObserverDelegate?

    func startObserving() {
        isObserving = true
        // In production: Register InspectlyURLProtocol or start Alamofire monitoring
        // URLProtocol.registerClass(InspectlyURLProtocol.self)
        print("[Inspectly] Network observation started")
    }

    func stopObserving() {
        isObserving = false
        // In production: Unregister URLProtocol
        // URLProtocol.unregisterClass(InspectlyURLProtocol.self)
        print("[Inspectly] Network observation stopped")
    }

    func setDelegate(_ delegate: NetworkObserverDelegate?) {
        self.delegate = delegate
    }

    // MARK: - Manual Capture

    /// Manually capture a request (called by URLProtocol or EventMonitor)
    func captureRequest(_ request: NetworkRequest) {
        delegate?.networkObserver(self, didCapture: request)
    }

    /// Update an existing captured request (e.g., when response arrives)
    func updateRequest(_ request: NetworkRequest) {
        delegate?.networkObserver(self, didUpdate: request)
    }
}

// MARK: - Mock Network Observer

final class MockNetworkObserverService: NetworkObserverProtocol {
    private(set) var isObserving: Bool = false

    func startObserving() { isObserving = true }
    func stopObserving() { isObserving = false }
    func setDelegate(_ delegate: NetworkObserverDelegate?) {}
}
