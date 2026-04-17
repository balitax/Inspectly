//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
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

    static let accentIndigo = Color.indigo
    static let accentTeal = Color.teal
    static let accentMint = Color.mint
    static let accentCyan = Color.cyan

    // MARK: - Tag Colors
    static let tagAuth = Color.orange
    static let tagAPI = Color.blue
    static let tagUpload = Color.green
    static let tagDownload = Color.cyan
    static let tagGraphQL = Color.purple
    static let tagWebSocket = Color.mint
    static let tagCritical = Color.red
    static let tagDebug = Color.gray

    // MARK: - Chart Colors
    static let chartPrimary = Color.indigo
    static let chartSecondary = Color.teal
    static let chartTertiary = Color.mint
    static let chartQuaternary = Color.cyan

    // MARK: - Stub Colors
    static let stubActive = Color.green
    static let stubInactive = Color.gray
    static let stubBadge = Color.indigo
}

// MARK: - ShapeStyle Extension

extension ShapeStyle where Self == Color {
    static var accentColor: Color { Color(red: 0.133, green: 0.698, blue: 0.322) }
}

extension Color {
    static var accentColor: Color { Color(red: 0.133, green: 0.698, blue: 0.322) }
}
