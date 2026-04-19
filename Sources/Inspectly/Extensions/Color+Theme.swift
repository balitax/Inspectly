//
//  Color+Theme.swift
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

import SwiftUI

// MARK: - Theme Colors

extension Color {
    // MARK: - Status Code Colors
    static let statusSuccess = Color.green
    static let statusRedirect = Color.blue
    static let statusClientError = Color.orange
    static let statusServerError = Color.red
    static let statusUnknown = Color.gray

    static func forStatusCode(_ code: Int?) -> Color {
        guard let code = code else { return .statusUnknown }
        switch code {
        case 200...299: return .statusSuccess
        case 300...399: return .statusRedirect
        case 400...499: return .statusClientError
        case 500...599: return .statusServerError
        default: return .statusUnknown
        }
    }

    // MARK: - HTTP Method Colors
    static let methodGET = Color(red: 0.35, green: 0.73, blue: 0.47)
    static let methodPOST = Color(red: 0.30, green: 0.55, blue: 0.95)
    static let methodPUT = Color(red: 0.95, green: 0.65, blue: 0.25)
    static let methodPATCH = Color(red: 0.75, green: 0.55, blue: 0.95)
    static let methodDELETE = Color(red: 0.95, green: 0.35, blue: 0.40)
    static let methodHEAD = Color(red: 0.55, green: 0.55, blue: 0.55)
    static let methodOPTIONS = Color(red: 0.50, green: 0.75, blue: 0.80)

    static func forMethod(_ method: HTTPMethodType) -> Color {
        switch method {
        case .get: return .methodGET
        case .post: return .methodPOST
        case .put: return .methodPUT
        case .patch: return .methodPATCH
        case .delete: return .methodDELETE
        case .head: return .methodHEAD
        case .options: return .methodOPTIONS
        }
    }

    // MARK: - Semantic Theme Colors
    static let cardBackground = Color(.systemBackground)
    static let cardBackgroundSecondary = Color(.secondarySystemBackground)
    static let cardBackgroundTertiary = Color(.tertiarySystemBackground)

    static let surfaceElevated = Color(.secondarySystemGroupedBackground)
    static let surfacePrimary = Color(.systemGroupedBackground)

    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)
    
    static let accentColor = Color(red: 0.890, green: 0.118, blue: 0.322)
    static let accentIndigo = Color(red: 0.345, green: 0.337, blue: 0.839)
    static let accentTeal = Color(red: 0.188, green: 0.690, blue: 0.780)
    static let accentMint = Color(red: 0.0, green: 0.780, blue: 0.745)
    static let accentCyan = Color(red: 0.196, green: 0.678, blue: 0.902)

    // MARK: - Tag Colors
    static let tagAuth = Color.orange
    static let tagAPI = Color.blue
    static let tagUpload = Color.green
    static let tagDownload = Color(red: 0.196, green: 0.678, blue: 0.902)
    static let tagGraphQL = Color.purple
    static let tagWebSocket = Color(red: 0.0, green: 0.780, blue: 0.745)
    static let tagCritical = Color.red
    static let tagDebug = Color.gray

    // MARK: - Chart Colors
    static let chartPrimary = accentColor
    static let chartSecondary = Color(red: 0.188, green: 0.690, blue: 0.780)
    static let chartTertiary = Color(red: 0.0, green: 0.780, blue: 0.745)
    static let chartQuaternary = Color(red: 0.196, green: 0.678, blue: 0.902)

    // MARK: - Stub Colors
    static let stubActive = Color.green
    static let stubInactive = Color.gray
    static let stubBadge = accentColor
}

// MARK: - ShapeStyle Extension

extension ShapeStyle where Self == Color {
    static var accentColor: Color { Color(red: 0.890, green: 0.118, blue: 0.322) }
}
