//
//  LargeResponsesSectionView.swift
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

// MARK: - Large Responses Section

@available(iOS 16.0, *)
struct LargeResponsesSectionView: View {
    @ObservedObject var viewModel: StatisticsViewModel

    var body: some View {
        StatsCardView(title: "Large Responses", subtitle: "Responses over 1 MB") {
            if viewModel.largeResponses.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(.green)
                    Text("No oversized responses detected")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.largeResponses.enumerated()), id: \.offset) { idx, request in
                        HStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(.orange)
                                .frame(width: 22, height: 22)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(request.shortURL)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)

                                Text(request.responseBody?.formattedSize ?? "—")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundStyle(.orange)
                            }

                            Spacer(minLength: 6)

                            StatusBadgeView(statusCode: request.statusCode)
                        }
                        .padding(.vertical, 8)

                        if idx < viewModel.largeResponses.count - 1 {
                            Divider().padding(.leading, 40)
                        }
                    }
                }
            }
        }
    }
}
