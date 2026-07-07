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
                LoggingSectionView(viewModel: viewModel)
                StubsSectionView(viewModel: viewModel)
                NetworkThrottlingSectionView(viewModel: viewModel)
                SlowRequestSectionView(viewModel: viewModel)
                IgnoredHostsSectionView(viewModel: viewModel)
                StorageSectionView(viewModel: viewModel)
                DisplaySectionView(viewModel: viewModel)
                DataManagementSectionView(viewModel: viewModel)
                AboutSectionView(viewModel: viewModel)
            }
            .listStyle(.insetGrouped)
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 90) }
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
}

// MARK: - Preview

@available(iOS 16.0, *)
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: .mock())
    }
}
