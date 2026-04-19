//
//  RequestDetailView.swift
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

// MARK: - Request Detail View

@available(iOS 16.0, *)
struct RequestDetailView: View {
    @StateObject var viewModel: RequestDetailViewModel

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Tab Selector
            tabSelector

            // MARK: - Tab Content
            TabView(selection: $viewModel.selectedTab) {
                OverviewTabView(viewModel: viewModel)
                    .tag(RequestDetailTab.overview)

                HeadersTabView(viewModel: viewModel)
                    .tag(RequestDetailTab.headers)

                ParamsTabView(viewModel: viewModel)
                    .tag(RequestDetailTab.params)

                RequestBodyTabView(viewModel: viewModel)
                    .tag(RequestDetailTab.requestBody)

                ResponseBodyTabView(viewModel: viewModel)
                    .tag(RequestDetailTab.responseBody)

                ExportTabView(viewModel: viewModel)
                    .tag(RequestDetailTab.export)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(Color.surfacePrimary)
        .navigationTitle(viewModel.request.shortURL)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                shareButton
            }
        }
        .overlay(alignment: .bottom) {
            if viewModel.copiedToClipboard {
                copiedBanner
            }
        }
        .sheet(item: $viewModel.createdStub) { stub in
            NavigationStack {
                StubDetailView(
                    viewModel: StubDetailViewModel(
                        stub: stub,
                        isEditing: true,
                        stubRepository: DependencyContainer.shared.stubRepository
                    )
                )
            }
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            ActivityView(activityItems: [viewModel.shareContent])
        }
        .sheet(item: $viewModel.shareURL) { identifiable in
            ActivityView(activityItems: [identifiable.url])
        }
        .toolbar(.hidden, for: .tabBar)
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(RequestDetailTab.allCases) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedTab = tab
                        }
                    } label: {
                        VStack(spacing: 6) {
                            HStack(spacing: 4) {
                                Image(systemName: tab.iconName)
                                    .font(.system(size: 10))
                                Text(tab.rawValue)
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(viewModel.selectedTab == tab ? .accentColor : .secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)

                            Rectangle()
                                .fill(viewModel.selectedTab == tab ? Color.accentColor : .clear)
                                .frame(height: 2)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
        }
        .background(Color.cardBackground)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    // MARK: - Share Button

    private var shareButton: some View {
        Menu {
            Button {
                viewModel.copyCURL()
            } label: {
                Label("Copy as cURL", systemImage: "terminal")
            }

            Button {
                viewModel.copyJSONBody()
            } label: {
                Label("Copy JSON Body", systemImage: "doc.on.clipboard")
            }

            Button {
                viewModel.copyFullRequest()
            } label: {
                Label("Copy Full Request", systemImage: "doc.on.doc")
            }

            Divider()

            Button {
                viewModel.shareRequest()
            } label: {
                Label("Share...", systemImage: "square.and.arrow.up")
            }

            Divider()

            Button {
                viewModel.createStub()
            } label: {
                Label("Create Stub", systemImage: "hammer")
            }
        } label: {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 14))
        }
    }

    // MARK: - Copied Banner

    private var copiedBanner: some View {
        Text("Copied to clipboard")
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.8))
            .clipShape(Capsule())
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .padding(.bottom, 20)
    }
}

// MARK: - Preview

@available(iOS 16.0, *)
struct RequestDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RequestDetailView(viewModel: .mock())
        }
    }
}
