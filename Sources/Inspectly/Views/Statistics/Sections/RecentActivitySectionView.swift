//
//  RecentActivitySectionView.swift
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

// MARK: - Recent Activity Section

@available(iOS 16.0, *)
struct RecentActivitySectionView: View {
    @ObservedObject var viewModel: StatisticsViewModel

    var body: some View {
        StatsCardView(title: "Recent Activity", subtitle: "Latest requests") {
            if viewModel.recentRequests.isEmpty {
                Text("No recent activity")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.recentRequests) { request in
                        RecentActivityRow(request: request)
                        if request.id != viewModel.recentRequests.last?.id {
                            Divider().padding(.leading, 46)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Recent Activity Row

@available(iOS 16.0, *)
private struct RecentActivityRow: View {
    let request: NetworkRequest

    private var statusAccentColor: Color {
        guard let code = request.statusCode else {
            return request.status == .timeout || request.status == .noInternet
                ? .red : Color(.quaternaryLabel)
        }
        return Color.forStatusCode(code)
    }

    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(statusAccentColor)
                .frame(width: 3)
                .padding(.vertical, 4)

            HTTPMethodBadge(method: request.method)

            VStack(alignment: .leading, spacing: 3) {
                Text(request.shortURL)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(request.timestamp.relativeTimeString)
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }

            Spacer(minLength: 6)

            StatusBadgeView(statusCode: request.statusCode)
        }
        .padding(.vertical, 8)
    }
}
