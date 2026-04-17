//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation

// MARK: - Network Observer Protocol

public protocol NetworkObserverProtocol {
    var isObserving: Bool { get }
    func startObserving()
    func stopObserving()
    func setDelegate(_ delegate: NetworkObserverDelegate?)
}

// MARK: - Network Observer Delegate

public protocol NetworkObserverDelegate: AnyObject {
    func networkObserver(_ observer: NetworkObserverProtocol, didCapture request: NetworkRequest)
    func networkObserver(_ observer: NetworkObserverProtocol, didUpdate request: NetworkRequest)
    func networkObserver(_ observer: NetworkObserverProtocol, didEncounterError error: Error)
}
