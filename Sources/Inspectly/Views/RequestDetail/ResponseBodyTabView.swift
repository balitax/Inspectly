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
                    // MARK: - Info Bar
                    infoBar

                    // MARK: - Body Content
                    if viewModel.request.responseContentType == .html && showPreview && !showRaw {
                        HTMLPreviewView(htmlContent: viewModel.request.responseBody?.rawString ?? "")
                    } else {
                        CodeBlockView(
                            title: "Response Body",
                            content: showRaw
                                ? (viewModel.request.responseBody?.rawString ?? "")
                                : viewModel.prettyResponseBody
                        )
                    }
                }
            }
            .padding(16)
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

            // Preview toggle (HTML only)
            if viewModel.request.responseContentType == .html {
                Toggle("Preview", isOn: $showPreview)
                    .toggleStyle(.button)
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                    .font(.system(size: 10, weight: .medium))
            }

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
}

// MARK: - Preview

struct ResponseBodyTabView_Previews: PreviewProvider {
    static var previews: some View {
        ResponseBodyTabView(viewModel: RequestDetailViewModel(request: NetworkRequest(method: .get, url: "https://api.example.com/users", host: "api.example.com", path: "/users")))
    }
}
