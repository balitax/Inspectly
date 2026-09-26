//
//  SettingsRowHelpers.swift
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

// MARK: - Settings Row Helpers

/// Shared row/icon/header styling used by every Settings section view.
enum SettingsRow {
    @ViewBuilder
    static func labeled(icon iconName: String, color: Color, title: String) -> some View {
        HStack(spacing: 12) {
            icon(iconName, color: color)
            Text(title)
                .font(.system(size: 15))
        }
    }

    static func icon(_ name: String, color: Color) -> some View {
        Image(systemName: name)
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(.white)
            .frame(width: 28, height: 28)
            .background(color)
            .cornerRadius(7)
    }

    static func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.secondary)
            .tracking(0.4)
    }
}
