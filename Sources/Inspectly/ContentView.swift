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
    @State private var appSettings: AppSettings = .default
    let onDismiss: (() -> Void)?
    let container: DependencyContainer

    init(container: DependencyContainer, isPresented: Binding<Bool>? = nil, onDismiss: (() -> Void)? = nil) {
        self.container = container
        self.onDismiss = onDismiss
    }

    private var colorScheme: ColorScheme? {
        guard let isDark = appSettings.isDarkModeOverride else { return nil }
        return isDark ? .dark : .light
    }

    var body: some View {
        Group {
            if #available(iOS 26, *) {
                nativeLiquidTabContent
            } else {
                floatingTabContent
            }
        }
        .preferredColorScheme(colorScheme)
        .task { await loadSettings() }
        .onReceive(NotificationCenter.default.publisher(for: .inspectlySettingsDidChange)) { notification in
            if let settings = notification.object as? AppSettings {
                appSettings = settings
            }
        }
    }

    // MARK: - iOS 26+ (Liquid Glass native floating tab bar)

    @available(iOS 26, *)
    private var nativeLiquidTabContent: some View {
        ZStack(alignment: .topLeading) {
            TabView(selection: $selectedTab) {
                requestsTab
                    .tabItem { Label("Requests", systemImage: "arrow.up.arrow.down.circle.fill") }
                    .tag(AppTab.requests)

                statisticsTab
                    .tabItem { Label("Statistics", systemImage: "chart.bar.fill") }
                    .tag(AppTab.statistics)

                stubsTab
                    .tabItem { Label("Stubs", systemImage: "hammer.fill") }
                    .tag(AppTab.stubs)

                settingsTab
                    .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                    .tag(AppTab.settings)
            }
            .tint(.accentColor)

            // Close button for fullscreen — floats above the liquid tab bar
            if let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 30))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 14)
                .padding(.leading, 20)
            }
        }
    }

    // MARK: - iOS 16–25 (Custom floating tab bar)

    private var floatingTabContent: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                requestsTab
                    .tag(AppTab.requests)
                    .toolbar(.hidden, for: .tabBar)

                statisticsTab
                    .tag(AppTab.statistics)
                    .toolbar(.hidden, for: .tabBar)

                stubsTab
                    .tag(AppTab.stubs)
                    .toolbar(.hidden, for: .tabBar)

                settingsTab
                    .tag(AppTab.settings)
                    .toolbar(.hidden, for: .tabBar)
            }
            .tint(.accentColor)

            FloatingTabBar(selectedTab: $selectedTab, onDismiss: onDismiss)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
        }
        .ignoresSafeArea(.keyboard)
    }

    // MARK: - Tab Content

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

    // MARK: - Settings

    private func loadSettings() async {
        if let loaded = try? await container.storageManager.load(AppSettings.self, forKey: "inspectly_settings") {
            appSettings = loaded
        }
    }
}

// MARK: - App Tab

enum AppTab: String, Hashable, CaseIterable {
    case requests
    case statistics
    case stubs
    case settings

    var title: String {
        switch self {
        case .requests:   return "Requests"
        case .statistics: return "Stats"
        case .stubs:      return "Stubs"
        case .settings:   return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .requests:   return "arrow.up.arrow.down.circle"
        case .statistics: return "chart.bar"
        case .stubs:      return "hammer"
        case .settings:   return "gearshape"
        }
    }

    var selectedIcon: String {
        switch self {
        case .requests:   return "arrow.up.arrow.down.circle.fill"
        case .statistics: return "chart.bar.fill"
        case .stubs:      return "hammer.fill"
        case .settings:   return "gearshape.fill"
        }
    }
}

// MARK: - Floating Tab Bar (iOS 16–25)

private struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab
    let onDismiss: (() -> Void)?

    var body: some View {
        HStack(spacing: 0) {
            // Tab buttons
            HStack(spacing: 4) {
                ForEach(AppTab.allCases) { tab in
                    tabButton(tab)
                }
            }
            .padding(6)
            .background(.ultraThinMaterial, in: Capsule())
            .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 6)

            // Close button
            if let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 36, height: 36)
                        .background(.ultraThinMaterial, in: Circle())
                        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
                }
                .padding(.leading, 10)
            }
        }
    }

    private func tabButton(_ tab: AppTab) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 17, weight: selectedTab == tab ? .semibold : .regular))
                    .frame(height: 20)
                Text(tab.title)
                    .font(.system(size: 9.5, weight: .medium))
            }
            .foregroundStyle(selectedTab == tab ? Color.accentColor : Color.secondary)
            .frame(width: 62)
            .padding(.vertical, 9)
            .background(
                selectedTab == tab ? Color.accentColor.opacity(0.1) : Color.clear,
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(container: .mock())
    }
}
