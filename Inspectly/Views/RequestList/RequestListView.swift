//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import SwiftUI

// MARK: - Request List View

struct RequestListView: View {
    @StateObject var viewModel: RequestListViewModel

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
            .task {
                await viewModel.loadRequests()
            }
        }
    }

    // MARK: - Request List

    private var requestList: some View {
        List {
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
        .listStyle(.insetGrouped)
        .navigationDestination(for: NetworkRequest.self) { request in
            RequestDetailView(viewModel: RequestDetailViewModel(request: request))
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
}

// MARK: - Preview

#Preview {
    RequestListView(viewModel: .mock())
}
