//
//  SecurityIssue.swift
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

// MARK: - Security Severity

enum SecuritySeverity: String, Codable, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"

    var id: String { rawValue }

    var colorName: String {
        switch self {
        case .low:    return "securityLow"
        case .medium: return "securityMedium"
        case .high:   return "securityHigh"
        case .critical: return "securityCritical"
        }
    }

    var iconName: String {
        switch self {
        case .low:    return "info.circle"
        case .medium: return "exclamationmark.triangle"
        case .high:   return "exclamationmark.octagon"
        case .critical: return "xmark.shield"
        }
    }

    var color: Color {
        switch self {
        case .low:    return .blue
        case .medium: return .yellow
        case .high:   return .orange
        case .critical: return .red
        }
    }
}

// MARK: - Security Category

enum SecurityCategory: String, Codable, Identifiable {
    case unencryptedHTTP = "Unencrypted HTTP"
    case missingSecurityHeader = "Missing Security Header"
    case exposedSecret = "Exposed Secret"
    case sensitiveInQuery = "Sensitive Data in URL"

    var id: String { rawValue }
}

// MARK: - Security Issue

struct SecurityIssue: Identifiable, Codable {
    let id: UUID
    let requestID: UUID
    let timestamp: Date
    let severity: SecuritySeverity
    let category: SecurityCategory
    let title: String
    let description: String

    init(
        id: UUID = UUID(),
        requestID: UUID,
        timestamp: Date = Date(),
        severity: SecuritySeverity,
        category: SecurityCategory,
        title: String,
        description: String
    ) {
        self.id = id
        self.requestID = requestID
        self.timestamp = timestamp
        self.severity = severity
        self.category = category
        self.title = title
        self.description = description
    }
}
