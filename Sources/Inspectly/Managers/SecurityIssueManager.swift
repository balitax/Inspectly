//
//  SecurityIssueManager.swift
//  Inspectly
//
//  Created by OpenCode on 27/09/2026.
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

// MARK: - Security Issue Manager

/// In-memory store for security issues detected by the scanner.
@MainActor
final class SecurityIssueManager: ObservableObject {
    static let shared = SecurityIssueManager()

    @Published private(set) var issues: [SecurityIssue] = []
    private let maxIssues = 500

    private init() {}

    func add(_ newIssues: [SecurityIssue]) {
        guard !newIssues.isEmpty else { return }
        issues.append(contentsOf: newIssues)
        if issues.count > maxIssues {
            issues.removeFirst(issues.count - maxIssues)
        }
    }

    func clear() {
        issues.removeAll()
    }

    func issues(for requestID: UUID) -> [SecurityIssue] {
        issues.filter { $0.requestID == requestID }
    }

    var issueCounts: (critical: Int, high: Int, medium: Int, low: Int) {
        (
            critical: issues.filter { $0.severity == .critical }.count,
            high: issues.filter { $0.severity == .high }.count,
            medium: issues.filter { $0.severity == .medium }.count,
            low: issues.filter { $0.severity == .low }.count
        )
    }
}
