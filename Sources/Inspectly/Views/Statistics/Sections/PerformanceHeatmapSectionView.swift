//
//  PerformanceHeatmapSectionView.swift
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

// MARK: - Performance Heatmap Section

@available(iOS 16.0, *)
struct PerformanceHeatmapSectionView: View {
    @ObservedObject var viewModel: StatisticsViewModel

    var body: some View {
        StatsCardView(title: "Performance Heatmap", subtitle: "Slowest endpoints") {
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
}
