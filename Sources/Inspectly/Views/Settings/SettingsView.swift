//
//  SettingsView.swift
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

// MARK: - Settings View

@available(iOS 16.0, *)
struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel

    var body: some View {
        InspectlyNavigationStack {
            List {
                loggingSection
                stubsSection
                networkThrottlingSection
                slowRequestSection
                ignoredHostsSection
                storageSection
                displaySection
                dataManagementSection
                aboutSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .alert("Clear All Logs?", isPresented: $viewModel.showClearConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    Task { await viewModel.clearLogs() }
                }
            } message: {
                Text("This will permanently delete all captured requests. This action cannot be undone.")
            }
            .alert("Export Error", isPresented: $viewModel.showExportError) {
                Button("OK") {}
            } message: {
                Text(viewModel.exportMessage)
            }
            .sheet(item: $viewModel.shareURL) { identifiable in
                ActivityView(activityItems: [identifiable.url])
            }
            .task {
                await viewModel.loadSettings()
            }
            .onChange(of: viewModel.settings.isLoggingEnabled) { _ in
                Task { await viewModel.saveSettings() }
            }
            .onChange(of: viewModel.settings.areStubsEnabled) { _ in
                Task { await viewModel.saveSettings() }
            }
            .onChange(of: viewModel.settings.networkThrottlingPreset) { _ in
                Task { await viewModel.saveSettings() }
            }
            .onChange(of: viewModel.settings.isShakeGestureEnabled) { _ in
                Task { await viewModel.saveSettings() }
            }
            .onChange(of: viewModel.settings.isAutoResponsePrettifying) { _ in
                Task { await viewModel.saveSettings() }
            }
            .onChange(of: viewModel.settings.isRequestBodyTruncation) { _ in
                Task { await viewModel.saveSettings() }
            }
            .onChange(of: viewModel.settings.slowRequestThreshold) { _ in
                Task { await viewModel.saveSettings() }
            }
        }
    }

    // MARK: - Logging Section

    private var loggingSection: some View {
        Section {
            Toggle(isOn: $viewModel.settings.isLoggingEnabled) {
                settingRow(
                    icon: "antenna.radiowaves.left.and.right",
                    color: .green,
                    title: "Enable Logging"
                )
            }
            .tint(.green)
        } header: {
            sectionHeader("Logging")
        } footer: {
            Text("When enabled, Inspectly captures all network requests and responses.")
        }
    }

    // MARK: - Stubs Section

    private var stubsSection: some View {
        Section {
            Toggle(isOn: $viewModel.settings.areStubsEnabled) {
                settingRow(
                    icon: "hammer.fill",
                    color: .accentIndigo,
                    title: "Enable Stubs Globally"
                )
            }
            .tint(.accentIndigo)
        } header: {
            sectionHeader("Stubs")
        } footer: {
            Text("When enabled, matching network requests will return stubbed responses.")
        }
    }

    // MARK: - Network Throttling

    private var networkThrottlingSection: some View {
        Section {
            HStack(spacing: 12) {
                settingIcon(viewModel.settings.networkThrottlingPreset.iconName, color: .orange)
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
                customThrottlingControls
            }
        } header: {
            sectionHeader("Network Throttling")
        } footer: {
            Text("Simulate slower connections or DNS failures for all real requests intercepted by Inspectly.")
        }
    }

    private var customThrottlingControls: some View {
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

    // MARK: - Slow Request Detection

    private var slowRequestSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    settingIcon("tortoise.fill", color: .orange)
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
            sectionHeader("Performance")
        } footer: {
            Text("Requests exceeding this duration will be highlighted with a slow indicator in the request list.")
        }
    }

    // MARK: - Ignored Hosts

    private var ignoredHostsSection: some View {
        Section {
            ForEach(viewModel.settings.ignoredHosts) { host in
                Toggle(isOn: Binding(
                    get: { host.isEnabled },
                    set: { _ in viewModel.toggleIgnoredHost(host) }
                )) {
                    Text(host.host)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(host.isEnabled ? .primary : .secondary)
                }
                .tint(.orange)
                .swipeActions {
                    Button(role: .destructive) {
                        viewModel.removeIgnoredHost(host)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }

            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(viewModel.newIgnoredHost.isEmpty ? Color(.tertiaryLabel) : .green)

                TextField("Add host to ignore...", text: $viewModel.newIgnoredHost)
                    .font(.system(size: 13, design: .monospaced))
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .onSubmit { viewModel.addIgnoredHost() }

                if !viewModel.newIgnoredHost.isEmpty {
                    Button {
                        viewModel.addIgnoredHost()
                    } label: {
                        Text("Add")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.green)
                    }
                }
            }
        } header: {
            sectionHeader("Ignored Hosts")
        } footer: {
            Text("Requests to these hosts will not be captured.")
        }
    }

    // MARK: - Storage

    private var storageSection: some View {
        Section {
            HStack(spacing: 12) {
                settingIcon("internaldrive.fill", color: .blue)
                Text("Max Stored Requests")
                    .font(.system(size: 15))
                Spacer()
                Picker("", selection: $viewModel.settings.maxStoredRequests) {
                    Text("100").tag(100)
                    Text("250").tag(250)
                    Text("500").tag(500)
                    Text("1000").tag(1000)
                    Text("2500").tag(2500)
                }
                .pickerStyle(.menu)
            }
        } header: {
            sectionHeader("Storage")
        } footer: {
            Text("Older requests are automatically removed when this limit is reached.")
        }
    }

    // MARK: - Display

    private var displaySection: some View {
        Section {
            HStack(spacing: 12) {
                settingIcon("circle.lefthalf.filled", color: .purple)
                Text("Theme")
                    .font(.system(size: 15))
                Spacer()
                Picker("", selection: Binding(
                    get: {
                        switch viewModel.settings.isDarkModeOverride {
                        case .some(true): return 2
                        case .some(false): return 1
                        case nil: return 0
                        }
                    },
                    set: { value in
                        switch value {
                        case 0: viewModel.settings.isDarkModeOverride = nil
                        case 1: viewModel.settings.isDarkModeOverride = false
                        case 2: viewModel.settings.isDarkModeOverride = true
                        default: viewModel.settings.isDarkModeOverride = nil
                        }
                    }
                )) {
                    Text("System").tag(0)
                    Text("Light").tag(1)
                    Text("Dark").tag(2)
                }
                .pickerStyle(.menu)
                .onChange(of: viewModel.settings.isDarkModeOverride) { _ in
                    Task { await viewModel.saveSettings() }
                }
            }

            Toggle(isOn: $viewModel.settings.isShakeGestureEnabled) {
                settingRow(
                    icon: "iphone.radiowaves.left.and.right",
                    color: .pink,
                    title: "Shake to Open"
                )
            }
            .tint(.pink)

            Toggle(isOn: $viewModel.settings.isAutoResponsePrettifying) {
                settingRow(
                    icon: "text.alignleft",
                    color: .accentTeal,
                    title: "Auto-Prettify JSON"
                )
            }
            .tint(.accentTeal)

            Toggle(isOn: $viewModel.settings.isRequestBodyTruncation) {
                settingRow(
                    icon: "scissors",
                    color: Color(.systemGray),
                    title: "Truncate Large Bodies"
                )
            }
            .tint(Color(.systemGray))
        } header: {
            sectionHeader("Display")
        }
    }

    // MARK: - Data Management

    private var dataManagementSection: some View {
        Section {
            Button {
                Task { await viewModel.exportLogs() }
            } label: {
                HStack(spacing: 12) {
                    settingIcon("arrow.up.doc.fill", color: .blue)
                    Text("Export Logs")
                        .font(.system(size: 15))
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(.tertiaryLabel))
                }
            }

            Button {
                Task { await viewModel.exportStubs() }
            } label: {
                HStack(spacing: 12) {
                    settingIcon("hammer.circle.fill", color: .accentIndigo)
                    Text("Export Stubs")
                        .font(.system(size: 15))
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(.tertiaryLabel))
                }
            }

            Button {
                viewModel.showClearConfirmation = true
            } label: {
                HStack(spacing: 12) {
                    settingIcon("trash.fill", color: .red)
                    Text("Clear All Logs")
                        .font(.system(size: 15))
                        .foregroundStyle(.red)
                    Spacer()
                }
            }
        } header: {
            sectionHeader("Data Management")
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        Section {
            HStack(spacing: 14) {
                Image(systemName: "network")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.accentIndigo)
                    .frame(width: 44, height: 44)
                    .background(Color.accentIndigo.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Inspectly")
                        .font(.system(size: 15, weight: .bold))
                    Text("Network debugger for iOS developers")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)

            HStack(spacing: 12) {
                settingIcon("tag.fill", color: Color(.systemGray))
                Text("Version")
                    .font(.system(size: 15))
                Spacer()
                Text("\(viewModel.appVersion) (\(viewModel.buildNumber))")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                settingIcon("person.fill", color: .pink)
                Text("Developer")
                    .font(.system(size: 15))
                Spacer()
                Text("Inspectly Team")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
        } header: {
            sectionHeader("About")
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func settingRow(icon: String, color: Color, title: String) -> some View {
        HStack(spacing: 12) {
            settingIcon(icon, color: color)
            Text(title)
                .font(.system(size: 15))
        }
    }

    private func settingIcon(_ name: String, color: Color) -> some View {
        Image(systemName: name)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 28, height: 28)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.secondary)
            .tracking(0.4)
    }
}

// MARK: - Preview

@available(iOS 16.0, *)
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: .mock())
    }
}
