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

@available(iOS 16.0, *)
struct ContentView: View {
    @State private var selectedTab: AppTab = .requests
    let onDismiss: (() -> Void)?

    let container: DependencyContainer

    init(container: DependencyContainer, isPresented: Binding<Bool>? = nil, onDismiss: (() -> Void)? = nil) {
        self.container = container
        self.onDismiss = onDismiss
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            RequestListView(
                viewModel: RequestListViewModel(
                    requestRepository: container.requestRepository
                )
            )
            .tabItem {
                Label("Requests", systemImage: "arrow.up.arrow.down.circle.fill")
            }
            .tag(AppTab.requests)

            StatisticsView(
                viewModel: StatisticsViewModel(
                    requestRepository: container.requestRepository
                )
            )
            .tabItem {
                Label("Statistics", systemImage: "chart.bar.fill")
            }
            .tag(AppTab.statistics)

            StubManagerView(
                viewModel: StubManagerViewModel(
                    stubRepository: container.stubRepository
                )
            )
            .tabItem {
                Label("Stubs", systemImage: "hammer.fill")
            }
            .tag(AppTab.stubs)

            SettingsView(
                viewModel: SettingsViewModel(
                    storageManager: container.storageManager,
                    exportManager: container.exportManager,
                    requestRepository: container.requestRepository,
                    stubRepository: container.stubRepository
                )
            )
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(AppTab.settings)
        }
        .tint(.accentColor)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if onDismiss != nil {
                    Button("Done") {
                        onDismiss?()
                    }
                }
            }
        }
    }
}

// MARK: - App Tab

enum AppTab: String, Hashable {
    case requests
    case statistics
    case stubs
    case settings
}

// MARK: - Preview

@available(iOS 16.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(container: .mock())
    }
}
