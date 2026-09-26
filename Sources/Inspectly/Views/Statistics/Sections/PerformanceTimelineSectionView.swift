//
//  PerformanceTimelineSectionView.swift
//  Inspectly
//
//  Created by OpenCode on 26/09/2026.
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

// MARK: - Performance Timeline Section

/// Card in Statistics that opens the full performance timeline waterfall.
struct PerformanceTimelineSectionView: View {
    @ObservedObject var viewModel: StatisticsViewModel

    var body: some View {
        StatsCardView(title: "Performance Timeline", subtitle: "Waterfall view") {
            InspectlyNavigationLink(destination: {
                PerformanceTimelineView(requests: viewModel.requests)
            }, label: {
                HStack(spacing: 12) {
                    SettingsRow.icon("chart.bar.horizontal", color: .blue)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("View Timeline")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.primary)

                        Text("\(viewModel.requests.count) requests · sequence, duration, and blocking")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(.tertiaryLabel))
                }
            })
        }
    }
}

// MARK: - Preview

struct PerformanceTimelineSectionView_Previews: PreviewProvider {
    static var previews: some View {
        PerformanceTimelineSectionView(viewModel: .mock())
            .padding()
    }
}
