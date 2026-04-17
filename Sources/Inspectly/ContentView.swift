//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import SwiftUI

// MARK: - Content View

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
        .tint(.primaryGreen)
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

#Preview {
    ContentView(container: .mock())
}
