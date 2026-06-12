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

// MARK: - Hide Floating Tab Bar Preference Key

struct HideFloatingTabBarKey: PreferenceKey {
    static var defaultValue = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

extension View {
    func hideFloatingTabBar(_ hidden: Bool = true) -> some View {
        preference(key: HideFloatingTabBarKey.self, value: hidden)
    }
}

// MARK: - Content View

struct ContentView: View {
    @State private var selectedTab: AppTab = .requests
    @State private var appSettings: AppSettings = .default
    @State private var isFloatingTabBarHidden = false
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
        floatingTabContent
            .preferredColorScheme(colorScheme)
            .task { await loadSettings() }
            .onReceive(NotificationCenter.default.publisher(for: .inspectlySettingsDidChange)) { notification in
                if let settings = notification.object as? AppSettings {
                    appSettings = settings
                }
            }
    }

    // MARK: - iOS 16–25 (Custom floating tab bar)

    private var floatingTabContent: some View {
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

            dismissTab
                .tag(AppTab.dismiss)
                .toolbar(.hidden, for: .tabBar)
        }
        .tint(.accentColor)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !isFloatingTabBarHidden {
                FloatingTabBar(selectedTab: $selectedTab, onDismiss: onDismiss)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    .padding(.top, 4)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onPreferenceChange(HideFloatingTabBarKey.self) { hidden in
            withAnimation(.easeInOut(duration: 0.2)) {
                isFloatingTabBarHidden = hidden
            }
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

    private var dismissTab: some View {
        VStack {
            Spacer()
            Button(action: {
                onDismiss?()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.secondary)
                    .padding(40)
                    .background {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay {
                                Circle()
                                    .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                            }
                            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
                    }
            }
            .buttonStyle(.plain)
            Spacer()
        }
    }

    // MARK: - Settings

    private func loadSettings() async {
        if let loaded = try? await container.storageManager.load(AppSettings.self, forKey: "inspectly_settings") {
            appSettings = loaded
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

    var selectedIcon: String {
        switch self {
        case .requests:   return "arrow.up.arrow.down.circle.fill"
        case .statistics: return "chart.bar.fill"
        case .stubs:      return "hammer.fill"
        case .settings:   return "gearshape.fill"
        case .dismiss:    return "xmark.circle.fill"
        }
    }
}

// MARK: - Floating Tab Bar (iOS 16–25, Liquid Glass-inspired)

private struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab
    let onDismiss: (() -> Void)?
    @Namespace private var tabNamespace

    var body: some View {
        HStack(spacing: 10) {
            // Main frosted glass pill
            HStack(spacing: 0) {
                ForEach(AppTab.allCases) { tab in
                    tabButton(tab)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Capsule()
                            .strokeBorder(Color.primary.opacity(0.12), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.18), radius: 32, x: 0, y: 10)
            }

            // // Close button — frosted glass circle
            // if let onDismiss {
            //     Button(action: onDismiss) {
            //         Image(systemName: "xmark")
            //             .font(.system(size: 16, weight: .bold))
            //             .foregroundStyle(.accentColor)
            //             .frame(width: 60, height: 60)
            //             .background {
            //                 Circle()
            //                     .fill(.red)
            //                     .overlay {
            //                         Circle()
            //                             .strokeBorder(.white.opacity(0.2), lineWidth: 0.5)
            //                     }
            //                     .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
            //             }
            //     }
            //     .buttonStyle(.plain)
            // }
        }
    }

    private func tabButton(_ tab: AppTab) -> some View {
        let isDismiss = tab == .dismiss
        let isSelected = selectedTab == tab && !isDismiss

        return Button {
            if isDismiss {
                onDismiss?()
            } else {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    selectedTab = tab
                }
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .frame(width: 26, height: 26)
                    .scaleEffect(isSelected ? 1.1 : 1.0)

                Text(tab.title)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(isDismiss ? .red : (isSelected ? Color.accentColor : Color.secondary))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Color(.systemBackground).opacity(0.7))
                        .overlay {
                            Capsule()
                                .strokeBorder(Color.accentColor.opacity(0.15), lineWidth: 0.5)
                        }
                        .matchedGeometryEffect(id: "tabHighlight", in: tabNamespace)
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: selectedTab)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(container: .mock())
    }
}
