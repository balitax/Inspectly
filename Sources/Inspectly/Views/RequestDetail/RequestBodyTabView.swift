//
//  RequestBodyTabView.swift
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

// MARK: - Request Body Tab View

@available(iOS 16.0, *)
struct RequestBodyTabView: View {
    @ObservedObject var viewModel: RequestDetailViewModel
    @State private var showRaw = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.request.requestBody?.isEmpty ?? true {
                    EmptyStateView(
                        icon: "arrow.up.doc",
                        title: "No Request Body",
                        subtitle: "This request doesn't contain a body."
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    // MARK: - Content Info
                    HStack {
                        Label(viewModel.request.requestContentType.displayName, systemImage: viewModel.request.requestContentType.iconName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)

                        Spacer()

                        if let size = viewModel.request.requestBody?.formattedSize {
                            Text(size)
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundStyle(.tertiary)
                        }

                        Toggle("Raw", isOn: $showRaw)
                            .toggleStyle(.button)
                            .buttonStyle(.bordered)
                            .controlSize(.mini)
                            .font(.system(size: 10, weight: .medium))
                    }

                    // MARK: - Body Content
                    CodeBlockView(
                        title: "Request Body",
                        content: showRaw
                            ? (viewModel.request.requestBody?.rawString ?? "")
                            : viewModel.prettyRequestBody
                    )
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Preview

@available(iOS 16.0, *)
struct RequestBodyTabView_Previews: PreviewProvider {
    static var previews: some View {
        RequestBodyTabView(viewModel: RequestDetailViewModel(request: NetworkRequest(method: .post, url: "https://api.example.com/login", host: "api.example.com", path: "/login")))
    }
}
