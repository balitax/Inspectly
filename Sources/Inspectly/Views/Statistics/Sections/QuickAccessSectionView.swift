//
//  QuickAccessSectionView.swift
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

// MARK: - Quick Access Section

@available(iOS 16.0, *)
struct QuickAccessSectionView: View {
    @ObservedObject var viewModel: StatisticsViewModel

    var body: some View {
        StatsCardView(title: "Quick Filters", subtitle: "Tap to filter requests") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    QuickAccessChip(icon: "xmark.octagon.fill", label: "Errors", count: viewModel.summary.failedRequests, color: .red)
                    QuickAccessChip(icon: "hammer.fill", label: "Stubbed", count: viewModel.summary.stubbedRequests, color: .accentIndigo)
                    QuickAccessChip(icon: "pin.fill", label: "Pinned", count: viewModel.summary.pinnedRequests, color: .orange)
                    QuickAccessChip(icon: "heart.fill", label: "Favorites", count: viewModel.summary.favoriteRequests, color: .pink)
                }
            }
        }
    }
}

// MARK: - Quick Access Chip

@available(iOS 16.0, *)
private struct QuickAccessChip: View {
    let icon: String
    let label: String
    let count: Int
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(count > 0 ? color : .secondary)

            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(count > 0 ? .primary : .secondary)

            Text("\(count)")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(count > 0 ? color : Color(.tertiaryLabel))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(count > 0 ? color.opacity(0.1) : Color(.quaternarySystemFill))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(count > 0 ? color.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}
