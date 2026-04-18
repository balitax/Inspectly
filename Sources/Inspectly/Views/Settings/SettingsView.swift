//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import SwiftUI

// MARK: - Settings View

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Logging Section
                loggingSection

                // MARK: - Stubs Section
                stubsSection

                // MARK: - Ignored Hosts
                ignoredHostsSection

                // MARK: - Storage
                storageSection

                // MARK: - Display
                displaySection

                // MARK: - Data Management
                dataManagementSection

                // MARK: - About
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
            .onChange(of: viewModel.settings.isShakeGestureEnabled) { _ in
                Task { await viewModel.saveSettings() }
            }
            .onChange(of: viewModel.settings.isAutoResponsePrettifying) { _ in
                Task { await viewModel.saveSettings() }
            }
            .onChange(of: viewModel.settings.isRequestBodyTruncation) { _ in
                Task { await viewModel.saveSettings() }
            }
        }
    }

    // MARK: - Logging Section

    private var loggingSection: some View {
        Section {
            Toggle(isOn: $viewModel.settings.isLoggingEnabled) {
                Label("Enable Logging", systemImage: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 14))
            }
            .tint(.green)
        } header: {
            Text("Logging")
        } footer: {
            Text("When enabled, Inspectly captures all network requests and responses.")
        }
    }

    // MARK: - Stubs Section

    private var stubsSection: some View {
        Section {
            Toggle(isOn: $viewModel.settings.areStubsEnabled) {
                Label("Enable Stubs Globally", systemImage: "hammer")
                    .font(.system(size: 14))
            }
            .tint(.primaryGreen)
        } header: {
            Text("Stubs")
        } footer: {
            Text("When enabled, matching network requests will return stubbed responses.")
        }
    }

    // MARK: - Ignored Hosts

    private var ignoredHostsSection: some View {
        Section {
            ForEach(viewModel.settings.ignoredHosts) { host in
                HStack {
                    Toggle(isOn: Binding(
                        get: { host.isEnabled },
                        set: { _ in viewModel.toggleIgnoredHost(host) }
                    )) {
                        Text(host.host)
                            .font(.system(size: 13, design: .monospaced))
                    }
                    .tint(.orange)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        viewModel.removeIgnoredHost(host)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }

            HStack {
                TextField("Add host to ignore...", text: $viewModel.newIgnoredHost)
                    .font(.system(size: 13, design: .monospaced))
                    .autocapitalization(.none)
                    .autocorrectionDisabled()

                Button {
                    viewModel.addIgnoredHost()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.accentColor)
                }
                .disabled(viewModel.newIgnoredHost.isEmpty)
            }
        } header: {
            Text("Ignored Hosts")
        } footer: {
            Text("Requests to these hosts will not be captured.")
        }
    }

    // MARK: - Storage

    private var storageSection: some View {
        Section {
            HStack {
                Label("Max Stored Requests", systemImage: "internaldrive")
                    .font(.system(size: 14))
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
            Text("Storage")
        }
    }

    // MARK: - Display

    private var displaySection: some View {
        Section {
            Toggle(isOn: $viewModel.settings.isShakeGestureEnabled) {
                Label("Shake to Open", systemImage: "iphone.radiowaves.left.and.right")
                    .font(.system(size: 14))
            }
            .tint(.accentColor)

            Toggle(isOn: $viewModel.settings.isAutoResponsePrettifying) {
                Label("Auto-Prettify JSON", systemImage: "text.alignleft")
                    .font(.system(size: 14))
            }
            .tint(.accentColor)

            Toggle(isOn: $viewModel.settings.isRequestBodyTruncation) {
                Label("Truncate Large Bodies", systemImage: "scissors")
                    .font(.system(size: 14))
            }
            .tint(.accentColor)
        } header: {
            Text("Display")
        }
    }

    // MARK: - Data Management

    private var dataManagementSection: some View {
        Section {
            Button {
                viewModel.showClearConfirmation = true
            } label: {
                Label("Clear All Logs", systemImage: "trash")
                    .font(.system(size: 14))
                    .foregroundStyle(.red)
            }

            Button {
                Task { await viewModel.exportLogs() }
            } label: {
                Label("Export Logs", systemImage: "square.and.arrow.up")
                    .font(.system(size: 14))
            }

            Button {
                Task { await viewModel.exportStubs() }
            } label: {
                Label("Export Stubs", systemImage: "square.and.arrow.up")
                    .font(.system(size: 14))
            }
        } header: {
            Text("Data Management")
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                    .font(.system(size: 14))
                Spacer()
                Text("\(viewModel.appVersion) (\(viewModel.buildNumber))")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Inspectly")
                    .font(.system(size: 15, weight: .semibold))

                Text("A premium network debugging tool for iOS developers. Inspect API requests, create stubs, and simulate errors — all directly inside your app.")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)

            HStack {
                Text("Developer")
                    .font(.system(size: 14))
                Spacer()
                Text("Built with ❤️ by Inspectly Team")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("About")
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView(viewModel: .mock())
}
