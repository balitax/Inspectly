//
//  InspectlyURLProtocol+Timing.swift
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

// MARK: - Timing Helpers

/// Shared delay/polling helpers used by both stub delivery and real request
/// delivery to simulate network throttling.
extension InspectlyURLProtocol {
    func dispatch(after delay: TimeInterval, execute block: @escaping () -> Void) {
        guard !isStopped else { return }

        if delay <= 0 {
            block()
            return
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self, !self.isStopped else { return }
            block()
        }
    }

    func waitResponsive(for delay: TimeInterval, completion: @escaping () -> Void) {
        guard delay > 0 else {
            completion()
            return
        }

        let start = Date()
        func check() {
            guard !isStopped else { return }
            let elapsed = Date().timeIntervalSince(start)
            if elapsed >= delay {
                completion()
            } else {
                let remaining = delay - elapsed
                let nextStep = min(remaining, 0.1) // Check every 100ms
                DispatchQueue.global().asyncAfter(deadline: .now() + nextStep) {
                    check()
                }
            }
        }
        check()
    }
}
