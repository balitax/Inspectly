//
//  MethodDistributionSectionView.swift
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

// MARK: - Method Distribution Section

@available(iOS 16.0, *)
struct MethodDistributionSectionView: View {
    @ObservedObject var viewModel: StatisticsViewModel

    var body: some View {
        StatsCardView(title: "Method Distribution", subtitle: "Breakdown by HTTP verb") {
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
}
