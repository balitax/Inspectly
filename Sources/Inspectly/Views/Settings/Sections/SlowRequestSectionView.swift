//
//  SlowRequestSectionView.swift
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

// MARK: - Slow Request Detection Section

@available(iOS 16.0, *)
struct SlowRequestSectionView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    SettingsRow.icon("tortoise.fill", color: .orange)
                    Text("Slow Request Threshold")
                        .font(.system(size: 15))
                    Spacer()
                    Text(String(format: "%.1fs", viewModel.settings.slowRequestThreshold))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundStyle(.orange)
                }

                Slider(
                    value: $viewModel.settings.slowRequestThreshold,
                    in: 0.5...10.0,
                    step: 0.5
                ) { _ in
                    Task { await viewModel.saveSettings() }
                }
                .tint(.orange)
            }
            .padding(.vertical, 4)
        } header: {
            SettingsRow.sectionHeader("Performance")
        } footer: {
            Text("Requests exceeding this duration will be highlighted with a slow indicator in the request list.")
        }
    }
}
