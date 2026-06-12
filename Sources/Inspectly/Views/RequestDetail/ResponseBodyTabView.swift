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

    private let lineIdPrefix = "responseLine"

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

    private var matchLineMap: [Int: Int] {
        guard !searchQuery.isEmpty, let body = currentBody else { return [:] }
        let lines = body.components(separatedBy: "\n")
        var map: [Int: Int] = [:]
        var globalIdx = 0
        let lowerQuery = searchQuery.lowercased()
        for (lineIdx, line) in lines.enumerated() {
            let lowerLine = line.lowercased()
            var pos = lowerLine.startIndex
            while let range = lowerLine.range(of: lowerQuery, range: pos..<lowerLine.endIndex) {
                map[globalIdx] = lineIdx
                globalIdx += 1
                pos = range.upperBound
            }
        }
        return map
    }

    var body: some View {
        VStack(spacing: 0) {
            if !(viewModel.request.responseBody?.isEmpty ?? true) {
                VStack(spacing: 8) {
                    infoBar
                    searchBar
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)
            }

            if viewModel.request.responseBody?.isEmpty ?? true {
                ScrollView {
                    EmptyStateView(
                        icon: "arrow.down.doc",
                        title: "No Response Body",
                        subtitle: "This request doesn't have a response body."
                    )
                    .frame(maxHeight: .infinity)
                    .padding(16)
                }
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 16) {
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
                                    totalMatches: matchCount,
                                    lineIdPrefix: lineIdPrefix
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .padding(.bottom, 100)
                    }
                    .onChange(of: currentMatch) { newMatch in
                        guard let targetLine = matchLineMap[newMatch] else { return }
                        withAnimation {
                            proxy.scrollTo("\(lineIdPrefix)_\(targetLine)", anchor: .center)
                        }
                    }
                    .onChange(of: searchQuery) { _ in
                        guard let targetLine = matchLineMap[0] else { return }
                        withAnimation {
                            proxy.scrollTo("\(lineIdPrefix)_\(targetLine)", anchor: .center)
                        }
                    }
                }
            }
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
        HStack(spacing: 8) {
            // Search field
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

            // Nav buttons — separate pill, always fully visible
            if !searchQuery.isEmpty {
                HStack(spacing: 6) {
                    Button {
                        if currentMatch > 0 { currentMatch -= 1 }
                    } label: {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .buttonStyle(.plain)
                    .disabled(currentMatch == 0 || matchCount == 0)
                    .opacity(currentMatch == 0 || matchCount == 0 ? 0.3 : 1)

                    Text("\(matchCount > 0 ? currentMatch + 1 : 0)/\(matchCount)")
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
                    .disabled(currentMatch >= matchCount - 1 || matchCount == 0)
                    .opacity(currentMatch >= matchCount - 1 || matchCount == 0 ? 0.3 : 1)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
    }
}

// MARK: - Preview

struct ResponseBodyTabView_Previews: PreviewProvider {
    static var previews: some View {
        ResponseBodyTabView(viewModel: RequestDetailViewModel(request: NetworkRequest(method: .get, url: "https://api.example.com/users", host: "api.example.com", path: "/users")))
    }
}
