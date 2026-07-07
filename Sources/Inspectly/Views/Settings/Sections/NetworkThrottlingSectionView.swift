//
//  NetworkThrottlingSectionView.swift
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

// MARK: - Network Throttling Section

@available(iOS 16.0, *)
struct NetworkThrottlingSectionView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Section {
            HStack(spacing: 12) {
                SettingsRow.icon(viewModel.settings.networkThrottlingPreset.iconName, color: .orange)
                Text("Preset")
                    .font(.system(size: 15))
                Spacer()
                Picker("", selection: $viewModel.settings.networkThrottlingPreset) {
                    ForEach(NetworkThrottlingPreset.allCases) { preset in
                        Text(preset.displayName).tag(preset)
                    }
                }
                .pickerStyle(.menu)
            }

            if viewModel.settings.networkThrottlingPreset != .off {
                HStack(alignment: .top, spacing: 12) {
                    Color.clear.frame(width: 28, height: 1)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(viewModel.settings.networkThrottlingPreset.displayName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.orange)
                        Text(viewModel.settings.networkThrottlingPreset.description)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 2)
            }

            if viewModel.settings.networkThrottlingPreset == .custom {
                CustomThrottlingControls(viewModel: viewModel)
            }
        } header: {
            SettingsRow.sectionHeader("Network Throttling")
        } footer: {
            Text("Simulate slower connections or DNS failures for all real requests intercepted by Inspectly.")
        }
    }
}

// MARK: - Custom Throttling Controls

@available(iOS 16.0, *)
private struct CustomThrottlingControls: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Request Delay")
                        .font(.system(size: 13, weight: .medium))
                    Spacer()
                    Text(String(format: "%.1fs", viewModel.settings.customNetworkDelay))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(.orange)
                }
                Slider(value: $viewModel.settings.customNetworkDelay, in: 0...30, step: 0.5) { _ in
                    Task { await viewModel.saveSettings() }
                }
                .tint(.orange)
            }

            VStack(alignment: .leading, spacing: 6) {
                Toggle(isOn: Binding(
                    get: { viewModel.settings.customNetworkBandwidth != nil },
                    set: { isEnabled in
                        viewModel.settings.customNetworkBandwidth = isEnabled ? 1_000_000 : nil
                        Task { await viewModel.saveSettings() }
                    }
                )) {
                    Text("Limit Bandwidth")
                        .font(.system(size: 13, weight: .medium))
                }
                .tint(.orange)

                if let bandwidth = viewModel.settings.customNetworkBandwidth {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Speed Limit")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(Int(bandwidth / 1024)) KB/s")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundStyle(.orange)
                        }
                        Slider(
                            value: Binding(
                                get: { bandwidth },
                                set: { viewModel.settings.customNetworkBandwidth = $0 }
                            ),
                            in: 8_192...10_000_000,
                            step: 8_192
                        ) { _ in
                            Task { await viewModel.saveSettings() }
                        }
                        .tint(.orange)
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }
}
