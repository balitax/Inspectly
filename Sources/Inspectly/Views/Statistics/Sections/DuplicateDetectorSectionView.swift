//
//  DuplicateDetectorSectionView.swift
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

// MARK: - Duplicate Detector Section

@available(iOS 16.0, *)
struct DuplicateDetectorSectionView: View {
    @ObservedObject var viewModel: StatisticsViewModel

    var body: some View {
        StatsCardView(title: "Duplicate Requests", subtitle: "Same endpoint hit multiple times") {
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
}
