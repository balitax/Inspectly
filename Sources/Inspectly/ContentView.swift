//
//  ContentView.swift
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

// MARK: - Content View

struct ContentView: View {
    @State private var selectedTab: AppTab = .requests
    @State private var previousTab: AppTab = .requests
    @State private var appSettings: AppSettings = .default
    @State private var notificationRequest: NetworkRequest?
    let onDismiss: (() -> Void)?
    let container: DependencyContainer

    init(container: DependencyContainer, onDismiss: (() -> Void)? = nil) {
        self.container = container
        self.onDismiss = onDismiss
    }

    private var colorScheme: ColorScheme? {
        guard let isDark = appSettings.isDarkModeOverride else { return nil }
        return isDark ? .dark : .light
    }

    var body: some View {
        tabContent
            .preferredColorScheme(colorScheme)
            .onAppear { loadSettings() }
            .onReceive(NotificationCenter.default.publisher(for: .inspectlySettingsDidChange)) { notification in
                if let settings = notification.object as? AppSettings {
                    appSettings = settings
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .inspectlyNotificationTapped)) { notification in
                if let requestID = notification.object as? UUID {
                    Task {
                        if let request = await container.requestRepository.getRequest(by: requestID) {
                            await MainActor.run {
                                selectedTab = .requests
                                notificationRequest = request
                            }
                        }
                    }
                }
            }
            .sheet(item: $notificationRequest) { request in
                InspectlyNavigationStack {
                    RequestDetailView(
                        viewModel: RequestDetailViewModel(
                            request: request,
                            requestRepository: container.requestRepository
                        )
                    )
                }
            }
    }

    // MARK: - Tab Content

    private var tabContent: some View {
        TabView(selection: $selectedTab) {
            requestsTab
                .tabItem {
                    Label(AppTab.requests.title, systemImage: AppTab.requests.icon)
                }
                .tag(AppTab.requests)

            statisticsTab
                .tabItem {
                    Label(AppTab.statistics.title, systemImage: AppTab.statistics.icon)
                }
                .tag(AppTab.statistics)

            stubsTab
                .tabItem {
                    Label(AppTab.stubs.title, systemImage: AppTab.stubs.icon)
                }
                .tag(AppTab.stubs)

            settingsTab
                .tabItem {
                    Label(AppTab.settings.title, systemImage: AppTab.settings.icon)
                }
                .tag(AppTab.settings)

            // Dismiss tab: does not keep selection, just closes the inspector
            dismissTab
                .tabItem {
                    Label(AppTab.dismiss.title, systemImage: AppTab.dismiss.icon)
                }
                .tag(AppTab.dismiss)
        }
        .accentColor(.accentColor)
        .onChange(of: selectedTab) { newTab in
            if newTab == .dismiss {
                selectedTab = previousTab
                onDismiss?()
            } else {
                previousTab = newTab
            }
        }
    }

    // MARK: - Tab Content Views

    private var requestsTab: some View {
        RequestListView(
            viewModel: RequestListViewModel(
                requestRepository: container.requestRepository,
                stubRepository: container.stubRepository
            ),
            stubRepository: container.stubRepository
        )
    }

    private var statisticsTab: some View {
        StatisticsView(
            viewModel: StatisticsViewModel(requestRepository: container.requestRepository)
        )
    }

    private var stubsTab: some View {
        StubManagerView(
            viewModel: StubManagerViewModel(
                stubRepository: container.stubRepository,
                requestRepository: container.requestRepository
            )
        )
    }

    private var settingsTab: some View {
        SettingsView(
            viewModel: SettingsViewModel(
                storageManager: container.storageManager,
                exportManager: container.exportManager,
                requestRepository: container.requestRepository,
                stubRepository: container.stubRepository
            )
        )
    }

    private var dismissTab: some View {
        Color.clear
            .onAppear {
                // Tab selection is restored via onChange; this guards against any missed state.
                if selectedTab == .dismiss {
                    selectedTab = previousTab
                }
                onDismiss?()
            }
    }

    // MARK: - Settings

    private func loadSettings() {
        Task {
            if let loaded = try? await container.storageManager.load(AppSettings.self, forKey: "inspectly_settings") {
                await MainActor.run {
                    appSettings = loaded
                }
            }
        }
    }
}

// MARK: - App Tab

enum AppTab: String, Hashable, CaseIterable, Identifiable {
    case requests
    case statistics
    case stubs
    case settings
    case dismiss

    var id: String { rawValue }

    var title: String {
        switch self {
        case .requests:   return "Requests"
        case .statistics: return "Stats"
        case .stubs:      return "Stubs"
        case .settings:   return "Settings"
        case .dismiss:    return "Dismiss"
        }
    }

    var icon: String {
        switch self {
        case .requests:   return "arrow.up.arrow.down.circle"
        case .statistics: return "chart.bar"
        case .stubs:      return "hammer"
        case .settings:   return "gearshape"
        case .dismiss:    return "xmark.circle"
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(container: .mock())
    }
}
