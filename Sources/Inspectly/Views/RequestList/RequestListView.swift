//
//  RequestListView.swift
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

// MARK: - Request List View

struct RequestListView: View {
    @StateObject var viewModel: RequestListViewModel
    let stubRepository: StubRepositoryProtocol

    init(
        viewModel: RequestListViewModel,
        stubRepository: StubRepositoryProtocol = DependencyContainer.shared.stubRepository
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.stubRepository = stubRepository
    }

    var body: some View {
        InspectlyNavigationStack {
            Group {
                if viewModel.isLoading && viewModel.requests.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.isEmpty {
                    if viewModel.hasActiveFilter {
                        EmptyStateView(
                            icon: "line.3.horizontal.decrease.circle",
                            title: "No Matching Requests",
                            subtitle: "Try adjusting your filters or search query.",
                            actionTitle: "Clear Filters"
                        ) {
                            viewModel.clearFilter()
                            viewModel.searchText = ""
                        }
                    } else {
                        EmptyStateView(
                            icon: "network.slash",
                            title: "No Requests Yet",
                            subtitle: "Start making API calls and Inspectly will automatically capture all network traffic."
                        )
                    }
                } else {
                    RequestListContentView(viewModel: viewModel, stubRepository: stubRepository)
                }
            }
            .background(Color.surfacePrimary)
            .navigationTitle("Requests")
            .searchable(text: $viewModel.searchText, prompt: "Search requests...")
            .onChange(of: viewModel.searchText) { newValue in
                viewModel.applyFiltersAndSort()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !viewModel.requests.isEmpty {
                        ClearRequestsButton(viewModel: viewModel)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    RequestSortMenu(viewModel: viewModel)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    RequestFilterButton(viewModel: viewModel)
                }
            }
            .sheet(isPresented: $viewModel.showFilterSheet) {
                FilterSheetView(filter: $viewModel.filter) {
                    viewModel.applyFiltersAndSort()
                }
            }
            .alert(isPresented: $viewModel.showClearConfirmation) {
                Alert(
                    title: Text("Clear All Requests?"),
                    message: Text("This will permanently delete all captured requests and stubs. This action cannot be undone."),
                    primaryButton: .cancel(Text("Cancel")),
                    secondaryButton: .destructive(Text("Clear")) {
                        Task { await viewModel.clearRequests() }
                    }
                )
            }
            .task {
                await viewModel.loadRequestsIfNeeded()
            }
            .onReceive(NotificationCenter.default.publisher(for: .inspectlyRequestsDidChange)) { _ in
                Task { await viewModel.refresh() }
            }
            .onReceive(NotificationCenter.default.publisher(for: .inspectlySettingsDidChange)) { notification in
                if let settings = notification.object as? AppSettings {
                    viewModel.activeThrottling = settings.networkThrottlingPreset
                    viewModel.slowRequestThreshold = settings.slowRequestThreshold
                }
            }
            .onAppear {
                Task {
                    await viewModel.refreshOnAppear()
                    await viewModel.loadThrottlingStatus()
                }
            }
        }
    }
}

// MARK: - Preview

struct RequestListView_Previews: PreviewProvider {
    static var previews: some View {
        RequestListView(viewModel: .mock())
    }
}
