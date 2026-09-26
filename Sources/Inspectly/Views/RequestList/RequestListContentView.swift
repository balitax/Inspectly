//
//  RequestListContentView.swift
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

// MARK: - Request List Content

/// The populated `List` body of `RequestListView` — banners, grouped rows, and
/// load-more footer. Split out since it needs both the view model and the stub
/// repository (for building the navigation destination), unlike the toolbar/banner
/// pieces which only need the view model.
struct RequestListContentView: View {
    @ObservedObject var viewModel: RequestListViewModel
    let stubRepository: StubRepositoryProtocol

    var body: some View {
        List {
            // Error Banner
            if let error = viewModel.errorMessage {
                ErrorBannerView(message: error)
            }

            // Throttling Banner
            if viewModel.activeThrottling != .off {
                ThrottlingBannerView(throttling: viewModel.activeThrottling)
            }

            // Active Filter Summary
            if viewModel.hasActiveFilter {
                ActiveFilterBarView(viewModel: viewModel)
            }

            ForEach(viewModel.groupedRequests) { group in
                Section {
                    ForEach(group.requests) { request in
                        InspectlyNavigationLink(destination: {
                            requestDetailDestination(for: request)
                        }, label: {
                            RequestRowView(request: request, slowThreshold: viewModel.slowRequestThreshold)
                        })
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
                                .controlSizeCompat(.small)
                        } else {
                            ProgressView()
                                .controlSizeCompat(.small)
                                .onAppear {
                                    Task { await viewModel.loadMore() }
                                }
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
            }
        }
        .id(viewModel.listRenderID)
        .listStyle(.insetGrouped)
        .overlay(
            Color.clear.frame(height: 90),
            alignment: .bottom
        )
    }

    // MARK: - Section Header

    private func sectionHeader(group: RequestGroup) -> some View {
        HStack(spacing: 6) {
            Text(group.title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(0.3)

            Text("\(group.requests.count)")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundColor(Color(.tertiaryLabel))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(.quaternarySystemFill))
                .cornerRadius(8)
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
}
