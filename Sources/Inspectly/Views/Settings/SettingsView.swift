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

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel

    var body: some View {
        InspectlyNavigationStack {
            List {
                Section {
                    StubsSectionView(viewModel: viewModel)
                    NetworkThrottlingSectionView(viewModel: viewModel)
                    SlowRequestSectionView(viewModel: viewModel)
                    IgnoredHostsSectionView(viewModel: viewModel)
                } header: {
                    SettingsRow.sectionHeader("Network & Capture")
                } footer: {
                    Text("Control how requests are intercepted, stubbed, throttled, slowed, or ignored.")
                }

                Section {
                    StorageSectionView(viewModel: viewModel)
                    DisplaySectionView(viewModel: viewModel)
                } header: {
                    SettingsRow.sectionHeader("Preferences")
                } footer: {
                    Text("Storage limits and display options for the inspector.")
                }

                Section {
                    NotificationsSectionView(viewModel: viewModel)
                } header: {
                    SettingsRow.sectionHeader("Notifications")
                } footer: {
                    Text("Get alerted for slow requests, errors, or requests to specific hosts.")
                }

                Section {
                    DataManagementSectionView(viewModel: viewModel)
                } header: {
                    SettingsRow.sectionHeader("Data Management")
                }

                Section {
                    AboutSectionView(viewModel: viewModel)
                } header: {
                    SettingsRow.sectionHeader("About")
                }
            }
            .listStyle(.insetGrouped)
            .overlay(
                Color.clear.frame(height: 90),
                alignment: .bottom
            )
            .navigationTitle("Settings")
            .alert(isPresented: $viewModel.showClearConfirmation) {
                Alert(
                    title: Text("Clear All Logs?"),
                    message: Text("This will permanently delete all captured requests. This action cannot be undone."),
                    primaryButton: .cancel(Text("Cancel")),
                    secondaryButton: .destructive(Text("Clear")) {
                        Task { await viewModel.clearLogs() }
                    }
                )
            }
            .alert(isPresented: $viewModel.showExportError) {
                Alert(
                    title: Text("Export Error"),
                    message: Text(viewModel.exportMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(item: $viewModel.shareURL) { identifiable in
                ActivityView(activityItems: [identifiable.url])
            }
            .task {
                await viewModel.loadSettings()
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
            .onChange(of: viewModel.settings.alertSlowRequests) { _ in
                Task { await viewModel.saveSettings() }
            }
            .onChange(of: viewModel.settings.alertErrorRequests) { _ in
                Task { await viewModel.saveSettings() }
            }
        }
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: .mock())
    }
}
