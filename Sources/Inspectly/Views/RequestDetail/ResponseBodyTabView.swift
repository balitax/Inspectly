//
//  ResponseBodyTabView.swift
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

// MARK: - Response Body Tab View

struct ResponseBodyTabView: View {
    @ObservedObject var viewModel: RequestDetailViewModel
    @State private var showRaw = false
    @State private var showPreview = true
    @State private var searchQuery = ""
    @State private var currentMatch = 0
    @FocusState private var searchFieldFocused: Bool

    private var matchCount: Int {
        guard !searchQuery.isEmpty,
              let body = currentBody else { return 0 }
        return body.lowercased().components(separatedBy: searchQuery.lowercased()).count - 1
    }

    private var currentBody: String? {
        showRaw
            ? (viewModel.request.responseBody?.rawString ?? "")
            : viewModel.prettyResponseBody
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.request.responseBody?.isEmpty ?? true {
                    EmptyStateView(
                        icon: "arrow.down.doc",
                        title: "No Response Body",
                        subtitle: "This request doesn't have a response body."
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    infoBar

                    searchBar

                    if viewModel.request.responseContentType == .html && showPreview && !showRaw {
                        HTMLPreviewView(htmlContent: viewModel.request.responseBody?.rawString ?? "")
                    } else {
                        CodeBlockView(
                            title: "Response Body",
                            content: showRaw
                                ? (viewModel.request.responseBody?.rawString ?? "")
                                : viewModel.prettyResponseBody,
                            searchQuery: searchQuery,
                            currentMatchIndex: searchQuery.isEmpty ? 0 : currentMatch,
                            totalMatches: matchCount
                        )
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Info Bar

    private var infoBar: some View {
        HStack(spacing: 10) {
            // Status badge
            StatusBadgeView(statusCode: viewModel.request.statusCode)

            // Content type pill
            Label(
                viewModel.request.responseContentType.displayName,
                systemImage: viewModel.request.responseContentType.iconName
            )
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color(.quaternarySystemFill))
            .clipShape(Capsule())

            Spacer()

            // Size
            if let size = viewModel.request.responseBody?.formattedSize {
                Text(size)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(.tertiary)
            }

            // Duration
            Text(viewModel.request.formattedDuration)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(.tertiary)

            // Raw toggle
            Toggle("Raw", isOn: $showRaw)
                .toggleStyle(.button)
                .buttonStyle(.bordered)
                .controlSize(.mini)
                .font(.system(size: 10, weight: .medium))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)

            TextField("Search JSON...", text: $searchQuery)
                .font(.system(size: 12, design: .monospaced))
                .textFieldStyle(.plain)
                .focused($searchFieldFocused)
                .onChange(of: searchQuery) { _ in
                    currentMatch = 0
                }

            if !searchQuery.isEmpty {
                HStack(spacing: 2) {
                    Button {
                        if currentMatch > 0 { currentMatch -= 1 }
                    } label: {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .buttonStyle(.plain)
                    .disabled(matchCount == 0)
                    .opacity(matchCount == 0 ? 0.3 : 1)

                    Text("\(currentMatch + 1)/\(matchCount)")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(matchCount > 0 ? Color.primary : Color.red)
                        .lineLimit(1)
                        .fixedSize()

                    Button {
                        if currentMatch < matchCount - 1 { currentMatch += 1 }
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .buttonStyle(.plain)
                    .disabled(matchCount == 0)
                    .opacity(matchCount == 0 ? 0.3 : 1)
                }

                Button {
                    searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

// MARK: - Preview

struct ResponseBodyTabView_Previews: PreviewProvider {
    static var previews: some View {
        ResponseBodyTabView(viewModel: RequestDetailViewModel(request: NetworkRequest(method: .get, url: "https://api.example.com/users", host: "api.example.com", path: "/users")))
    }
}
