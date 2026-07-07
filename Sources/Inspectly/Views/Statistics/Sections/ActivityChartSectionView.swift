//
//  ActivityChartSectionView.swift
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

// MARK: - Activity Chart Section

@available(iOS 16.0, *)
struct ActivityChartSectionView: View {
    @ObservedObject var viewModel: StatisticsViewModel

    var body: some View {
        StatsCardView(title: "Hourly Activity", subtitle: "Requests over 24h") {
            MiniChartView(data: viewModel.hourlyData.map { Double($0.count) })
                .frame(height: 80)
        }
    }
}
