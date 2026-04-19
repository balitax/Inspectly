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
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Summary Cards
                    summaryCardsSection

                    // MARK: - Activity Chart
                    activityChartSection

                    // MARK: - Method Distribution
                    methodDistributionSection

                    // MARK: - Quick Access
                    quickAccessSection

                    // MARK: - Recent Activity
                    recentActivitySection
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color.surfacePrimary)
            .navigationTitle("Statistics")
            .refreshable {
                await viewModel.loadData()
            }
            .task {
                await viewModel.loadData()
            }
        }
    }

    // MARK: - Summary Cards

    private var summaryCardsSection: some View {
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

    // MARK: - Activity Chart

    private var activityChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Hourly Activity", subtitle: "Requests over 24h")

            MiniChartView(data: viewModel.hourlyData.map { Double($0.count) })
                .frame(height: 80)
        }
        .cardStyle()
    }

    // MARK: - Method Distribution

    private var methodDistributionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Method Distribution")

            if viewModel.topMethods.isEmpty {
                Text("No data yet")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.topMethods, id: \.method) { item in
                        HStack(spacing: 10) {
                            HTTPMethodBadge(method: item.method)

                            GeometryReader { geo in
                                let total = max(viewModel.summary.totalRequests, 1)
                                let width = geo.size.width * CGFloat(item.count) / CGFloat(total)

                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(Color.forMethod(item.method).opacity(0.3))
                                    .frame(width: max(width, 4), height: 20)
                                    .overlay(alignment: .trailing) {
                                        Text("\(item.count)")
                                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                                            .foregroundStyle(.secondary)
                                            .padding(.trailing, 6)
                                    }
                            }
                            .frame(height: 20)
                        }
                    }
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Quick Access

    private var quickAccessSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Quick Filters")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    QuickAccessChip(icon: "xmark.octagon.fill", label: "Errors", count: viewModel.summary.failedRequests, color: .red)
                    QuickAccessChip(icon: "tortoise.fill", label: "Slow", count: 0, color: .orange)
                    QuickAccessChip(icon: "hammer.fill", label: "Stubbed", count: viewModel.summary.stubbedRequests, color: .accentColor)
                    QuickAccessChip(icon: "pin.fill", label: "Pinned", count: viewModel.summary.pinnedRequests, color: .yellow)
                    QuickAccessChip(icon: "heart.fill", label: "Favorites", count: viewModel.summary.favoriteRequests, color: .pink)
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Recent Activity

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Recent Activity", subtitle: "Latest requests")

            if viewModel.recentRequests.isEmpty {
                Text("No recent activity")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.recentRequests) { request in
                        RecentActivityRow(request: request)

                        if request.id != viewModel.recentRequests.last?.id {
                            Divider()
                                .padding(.leading, 44)
                        }
                    }
                }
            }
        }
        .cardStyle()
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
                .foregroundStyle(color)

            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.primary)

            Text("\(count)")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.tertiarySystemFill))
        .clipShape(Capsule())
    }
}

// MARK: - Recent Activity Row

@available(iOS 16.0, *)
private struct RecentActivityRow: View {
    let request: NetworkRequest

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: request.status.iconName)
                .font(.system(size: 14))
                .foregroundStyle(Color.forStatusCode(request.statusCode))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    HTTPMethodBadge(method: request.method)
                    Text(request.shortURL)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }

                Text(request.timestamp.relativeTimeString)
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            StatusBadgeView(statusCode: request.statusCode)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

@available(iOS 16.0, *)
struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView(viewModel: .mock())
    }
}
