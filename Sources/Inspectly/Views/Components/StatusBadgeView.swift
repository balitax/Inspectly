//
//  StatusBadgeView.swift
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

// MARK: - Status Badge View

@available(iOS 16.0, *)
struct StatusBadgeView: View {
    let statusCode: Int?

    var body: some View {
        Text(statusCode.map { "\($0)" } ?? "—")
            .font(.system(size: 12, weight: .bold, design: .monospaced))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor.opacity(0.15))
            .foregroundStyle(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    private var backgroundColor: Color {
        Color.forStatusCode(statusCode)
    }
}

// MARK: - Preview

@available(iOS 16.0, *)
struct StatusBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            StatusBadgeView(statusCode: 200)
            StatusBadgeView(statusCode: 301)
            StatusBadgeView(statusCode: 404)
            StatusBadgeView(statusCode: 500)
            StatusBadgeView(statusCode: nil)
        }
        .padding()
    }
}
