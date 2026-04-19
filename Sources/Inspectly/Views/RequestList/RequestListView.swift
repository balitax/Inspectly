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

@available(iOS 16.0, *)
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
        NavigationStack {
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
                    requestList
                }
            }
            .background(Color.surfacePrimary)
            .navigationTitle("Requests")
            .searchable(text: $viewModel.searchText, prompt: "Search URL, method, status...")
            .onChange(of: viewModel.searchText) { _ in
                viewModel.applyFiltersAndSort()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !viewModel.requests.isEmpty {
                        clearButton
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    sortMenu
                }

                ToolbarItem(placement: .topBarTrailing) {
                    filterButton
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .sheet(isPresented: $viewModel.showFilterSheet) {
                FilterSheetView(filter: $viewModel.filter) {
                    viewModel.applyFiltersAndSort()
                }
                .presentationDetents([.medium, .large])
            }
            .alert("Clear All Requests?", isPresented: $viewModel.showClearConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    Task { await viewModel.clearRequests() }
                }
            } message: {
                Text("This will permanently delete all captured requests from the Requests tab. This action cannot be undone.")
            }
            .task {
                await viewModel.loadRequestsIfNeeded()
            }
            .onReceive(NotificationCenter.default.publisher(for: .inspectlyRequestsDidChange)) { _ in
                Task {
                    await viewModel.refresh()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .inspectlySettingsDidChange)) { notification in
                if let settings = notification.object as? AppSettings {
                    viewModel.activeThrottling = settings.networkThrottlingPreset
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

    // MARK: - Request List

    private var requestList: some View {
        List {
            // Throttling Banner
            if viewModel.activeThrottling != .off {
                throttlingBanner
            }

            // Active Filter Summary
            if viewModel.hasActiveFilter {
                activeFilterBar
            }

            ForEach(viewModel.groupedRequests) { group in
                Section {
                    ForEach(group.requests) { request in
                        NavigationLink(value: request) {
                            RequestRowView(request: request)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Task { await viewModel.deleteRequest(request) }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                Task { await viewModel.togglePin(request) }
                            } label: {
                                Label(
                                    request.isPinned ? "Unpin" : "Pin",
                                    systemImage: request.isPinned ? "pin.slash" : "pin"
                                )
                            }
                            .tint(.orange)

                            Button {
                                Task { await viewModel.toggleFavorite(request) }
                            } label: {
                                Label(
                                    request.isFavorite ? "Unfavorite" : "Favorite",
                                    systemImage: request.isFavorite ? "heart.slash" : "heart"
                                )
                            }
                            .tint(.pink)
                        }
                    }
                } header: {
                    Text(group.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .id(viewModel.listRenderID)
        .listStyle(.insetGrouped)
        .navigationDestination(for: NetworkRequest.self) { request in
            RequestDetailView(
                viewModel: RequestDetailViewModel(
                    request: request,
                    requestRepository: viewModel.requestRepository
                ),
                stubRepository: stubRepository,
                onStubSaved: { savedStub in
                    viewModel.markRequestAsStubbed(request.id, stubId: savedStub.id)
                    await viewModel.refresh()
                },
                onDismissed: {
                    Task {
                        await viewModel.refresh()
                    }
                }
            )
        }
    }

    // MARK: - Sort Menu

    private var sortMenu: some View {
        Menu {
            ForEach(RequestSortOption.allCases) { option in
                Button {
                    viewModel.sortOption = option
                    viewModel.applyFiltersAndSort()
                } label: {
                    Label {
                        Text(option.rawValue)
                    } icon: {
                        if viewModel.sortOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 14))
        }
    }

    // MARK: - Clear Button

    private var clearButton: some View {
        Button(role: .destructive) {
            viewModel.showClearConfirmation = true
        } label: {
            Image(systemName: "trash")
                .font(.system(size: 14))
        }
    }

    // MARK: - Filter Button

    private var filterButton: some View {
        Button {
            viewModel.showFilterSheet = true
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 14))

                if viewModel.filter.isActive {
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)
                        .offset(x: 4, y: -4)
                }
            }
        }
    }

    // MARK: - Active Filter Bar

    private var activeFilterBar: some View {
        HStack {
            Image(systemName: "line.3.horizontal.decrease")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)

            Text("\(viewModel.totalFilteredCount) results")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)

            Spacer()

            Button("Clear") {
                viewModel.clearFilter()
                viewModel.searchText = ""
            }
            .font(.system(size: 12, weight: .medium))
        }
        .listRowBackground(Color.clear)
    }

    // MARK: - Throttling Banner

    private var throttlingBanner: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 32, height: 32)

                Image(systemName: viewModel.activeThrottling.iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.orange)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Network Throttling Active: \(viewModel.activeThrottling.displayName)")
                    .font(.system(size: 13, weight: .bold))

                Text(viewModel.activeThrottling.description)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.secondary.opacity(0.5))
        }
        .padding(.vertical, 4)
        .listRowBackground(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.05))
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
        )
        .listRowSeparator(.hidden)
    }
}

// MARK: - Preview

@available(iOS 16.0, *)
struct RequestListView_Previews: PreviewProvider {
    static var previews: some View {
        RequestListView(viewModel: .mock())
    }
}
