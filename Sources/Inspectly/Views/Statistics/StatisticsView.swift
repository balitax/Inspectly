//
//  StatisticsView.swift
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

// MARK: - Statistics View

@available(iOS 16.0, *)
struct StatisticsView: View {
    @StateObject var viewModel: StatisticsViewModel

    var body: some View {
        InspectlyNavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SummaryCardsSectionView(viewModel: viewModel)
                    ActivityChartSectionView(viewModel: viewModel)
                    MethodDistributionSectionView(viewModel: viewModel)
                    PerformanceHeatmapSectionView(viewModel: viewModel)
                    DuplicateDetectorSectionView(viewModel: viewModel)
                    LargeResponsesSectionView(viewModel: viewModel)
                    QuickAccessSectionView(viewModel: viewModel)
                    RecentActivitySectionView(viewModel: viewModel)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color.surfacePrimary)
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 90) }
            .navigationTitle("Statistics")
            .refreshable {
                await viewModel.loadData()
            }
            .task {
                await viewModel.loadData()
            }
            .onReceive(NotificationCenter.default.publisher(for: .inspectlyRequestsDidChange)) { _ in
                Task { await viewModel.loadData() }
            }
        }
    }
}

// MARK: - Preview

@available(iOS 16.0, *)
struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView(viewModel: .mock())
    }
}
