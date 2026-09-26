//
//  StatsCardView.swift
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

// MARK: - Stats Card

/// Shared card chrome (title/subtitle header + divider + content) used by every
/// Statistics section.
struct StatsCardView<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .tracking(0.4)

                if let subtitle = subtitle {
                    Text("·")
                        .foregroundColor(.quaternaryLabel)
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundColor(.tertiaryLabel)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 10)

            Divider().padding(.horizontal, 14)

            content
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
        }
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}
