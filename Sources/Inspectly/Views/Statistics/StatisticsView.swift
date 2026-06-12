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

struct StatisticsView: View {
    @StateObject var viewModel: StatisticsViewModel

    var body: some View {
        InspectlyNavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    summaryCardsSection
                    activityChartSection
                    methodDistributionSection
                    performanceHeatmapSection
                    duplicateDetectorSection
                    largeResponsesSection
                    quickAccessSection
                    recentActivitySection
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
        statsCard(title: "Hourly Activity", subtitle: "Requests over 24h") {
            MiniChartView(data: viewModel.hourlyData.map { Double($0.count) })
                .frame(height: 80)
        }
    }

    // MARK: - Method Distribution

    private var methodDistributionSection: some View {
        statsCard(title: "Method Distribution", subtitle: "Breakdown by HTTP verb") {
            if viewModel.topMethods.isEmpty {
                Text("No data yet")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.topMethods, id: \.method) { item in
                        HStack(spacing: 10) {
                            HTTPMethodBadge(method: item.method)

                            GeometryReader { geo in
                                let total = max(viewModel.summary.totalRequests, 1)
                                let width = geo.size.width * CGFloat(item.count) / CGFloat(total)

                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(Color(.quaternarySystemFill))
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(Color.forMethod(item.method).opacity(0.35))
                                        .frame(width: max(width, 4))
                                }
                                .overlay(alignment: .trailing) {
                                    Text("\(item.count)")
                                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                        .padding(.trailing, 6)
                                }
                            }
                            .frame(height: 22)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Performance Heatmap

    private var performanceHeatmapSection: some View {
        statsCard(title: "Performance Heatmap", subtitle: "Slowest endpoints") {
            if viewModel.endpointPerformance.isEmpty {
                Text("No timing data yet")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.endpointPerformance, id: \.path) { item in
                        HStack(spacing: 10) {
                            Text(item.path)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                                .frame(maxWidth: 130, alignment: .leading)

                            GeometryReader { geo in
                                let maxTime = viewModel.endpointPerformance.first?.avgTime ?? 1
                                let fillWidth = geo.size.width * CGFloat(item.avgTime / max(maxTime, 0.001))

                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(Color(.quaternarySystemFill))
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(perfTimeColor(item.avgTime).opacity(0.35))
                                        .frame(width: max(fillWidth, 4))
                                }
                                .overlay(alignment: .trailing) {
                                    Text(formattedDuration(item.avgTime))
                                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                        .foregroundStyle(perfTimeColor(item.avgTime))
                                        .padding(.trailing, 6)
                                }
                            }
                            .frame(height: 22)
                        }
                    }
                }
            }
        }
    }

    private func perfTimeColor(_ time: TimeInterval) -> Color {
        if time >= 2.0 { return .red }
        if time >= 0.5 { return .orange }
        return .green
    }

    private func formattedDuration(_ time: TimeInterval) -> String {
        if time < 1 { return String(format: "%.0fms", time * 1000) }
        return String(format: "%.2fs", time)
    }

    // MARK: - Duplicate Detector

    private var duplicateDetectorSection: some View {
        statsCard(title: "Duplicate Requests", subtitle: "Same endpoint hit multiple times") {
            if viewModel.duplicateGroups.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(.green)
                    Text("No duplicate requests detected")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.duplicateGroups.enumerated()), id: \.offset) { idx, group in
                        HStack(spacing: 10) {
                            HTTPMethodBadge(method: group.method)

                            Text(group.path)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundStyle(.primary)
                                .lineLimit(1)

                            Spacer(minLength: 6)

                            Text("×\(group.count)")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundStyle(.orange)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.orange.opacity(0.12))
                                .clipShape(Capsule())
                        }
                        .padding(.vertical, 8)

                        if idx < viewModel.duplicateGroups.count - 1 {
                            Divider().padding(.leading, 46)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Large Responses

    private var largeResponsesSection: some View {
        statsCard(title: "Large Responses", subtitle: "Responses over 1 MB") {
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

    // MARK: - Quick Access

    private var quickAccessSection: some View {
        statsCard(title: "Quick Filters", subtitle: "Tap to filter requests") {
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

    // MARK: - Recent Activity

    private var recentActivitySection: some View {
        statsCard(title: "Recent Activity", subtitle: "Latest requests") {
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

    // MARK: - Stats Card Helper

    private func statsCard<Content: View>(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .tracking(0.4)

                if let subtitle = subtitle {
                    Text("·")
                        .foregroundStyle(.quaternary)
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 10)

            Divider().padding(.horizontal, 14)

            content()
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
        }
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Quick Access Chip

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

// MARK: - Recent Activity Row

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

// MARK: - Preview

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView(viewModel: .mock())
    }
}
