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
                ToolbarItem(placement: .navigationBarLeading) {
                    if !viewModel.requests.isEmpty {
                        clearButton
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    sortMenu
                }
                ToolbarItem(placement: .navigationBarTrailing) {
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
                .inspectlyPresentationDetents([.medium, .large])
            }
            .alert("Clear All Requests?", isPresented: $viewModel.showClearConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    Task { await viewModel.clearRequests() }
                }
            } message: {
                Text("This will permanently delete all captured requests and stubs. This action cannot be undone.")
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

    // MARK: - Request List

    private var requestList: some View {
        List {
            // Error Banner
            if let error = viewModel.errorMessage {
                errorBanner(message: error)
            }

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

                        InspectlyNavigationLink(value: request) { request in
                            requestDetailDestination(for: request)
                        } label: {
                            RequestRowView(request: request, slowThreshold: viewModel.slowRequestThreshold)
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
                    sectionHeader(group: group)
                }
            }

            // Load More
            if viewModel.hasMore {
                Section {
                    HStack {
                        Spacer()
                        if viewModel.isLoadingMore {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            ProgressView()
                                .controlSize(.small)
                                .onAppear {
                                    Task { await viewModel.loadMore() }
                                }
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
        }
        .id(viewModel.listRenderID)
        .listStyle(.insetGrouped)
        .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 90) }
        .inspectlyNavigationDestination(for: NetworkRequest.self) { request in
            requestDetailDestination(for: request)
        }
    }

    // MARK: - Section Header

    private func sectionHeader(group: RequestGroup) -> some View {
        HStack(spacing: 6) {
            Text(group.title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .tracking(0.3)

            Text("\(group.requests.count)")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(.quaternarySystemFill))
                .clipShape(Capsule())
        }
    }

    // MARK: - Navigation Destination

    @ViewBuilder
    private func requestDetailDestination(for request: NetworkRequest) -> some View {
        RequestDetailView(
            viewModel: RequestDetailViewModel(
                request: request,
                requestRepository: viewModel.requestRepository
            ),
            stubRepository: stubRepository,
            onStubSaved: { savedStub in
                await viewModel.markRequestsAsStubbed(using: savedStub)
            },
            onDismissed: {
                Task { await viewModel.refresh() }
            }
        )
    }

    // MARK: - Toolbar

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

    private var clearButton: some View {
        Button(role: .destructive) {
            viewModel.showClearConfirmation = true
        } label: {
            Image(systemName: "trash")
                .font(.system(size: 14))
        }
    }

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
        HStack(spacing: 8) {
            Image(systemName: "line.3.horizontal.decrease")
                .font(.system(size: 11))
                .foregroundStyle(.accentColor)

            Text("\(viewModel.totalFilteredCount) results")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.primary)

            Text("filtered")
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)

            Spacer()

            Button {
                viewModel.clearFilter()
                viewModel.searchText = ""
            } label: {
                Text("Clear")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    // MARK: - Error Banner

    private func errorBanner(message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.red)
                .frame(width: 32, height: 32)
                .background(Color.red.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text("Storage Error")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.red)

                Text(message)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(.vertical, 6)
        .listRowBackground(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.red.opacity(0.07))
                .padding(.horizontal, 4)
                .padding(.vertical, 3)
        )
        .listRowSeparator(.hidden)
    }

    // MARK: - Throttling Banner

    private var throttlingBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: viewModel.activeThrottling.iconName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.orange)
                .frame(width: 32, height: 32)
                .background(Color.orange.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text("Throttling: \(viewModel.activeThrottling.displayName)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.orange)

                Text(viewModel.activeThrottling.description)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.vertical, 6)
        .listRowBackground(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.orange.opacity(0.07))
                .padding(.horizontal, 4)
                .padding(.vertical, 3)
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
