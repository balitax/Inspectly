//
//  NetworkObserverProtocol.swift
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
