//
//  SummaryCardsSectionView.swift
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

// MARK: - Summary Cards Section

@available(iOS 16.0, *)
struct SummaryCardsSectionView: View {
    @ObservedObject var viewModel: StatisticsViewModel

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            SummaryCardView(
                title: "Total Requests",
                value: "\(viewModel.summary.totalRequests)",
                icon: "arrow.up.arrow.down",
                color: .accentIndigo
            )
            SummaryCardView(
                title: "Failed",
                value: "\(viewModel.summary.failedRequests)",
                icon: "xmark.circle.fill",
                color: .statusServerError
            )
            SummaryCardView(
                title: "Avg Response",
                value: viewModel.summary.formattedAverageTime,
                icon: "clock.fill",
                color: .accentTeal
            )
            SummaryCardView(
                title: "Success Rate",
                value: viewModel.summary.formattedSuccessRate,
                icon: "checkmark.seal.fill",
                color: .statusSuccess
            )
            SummaryCardView(
                title: "Pinned",
                value: "\(viewModel.summary.pinnedRequests)",
                icon: "pin.fill",
                color: .orange
            )
            SummaryCardView(
                title: "Favorites",
                value: "\(viewModel.summary.favoriteRequests)",
                icon: "heart.fill",
                color: .pink
            )
        }
    }
}
