//
//  ParamsTabView.swift
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

// MARK: - Params Tab View

@available(iOS 16.0, *)
struct ParamsTabView: View {
    @ObservedObject var viewModel: RequestDetailViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.request.queryParameters.isEmpty {
                    EmptyStateView(
                        icon: "questionmark.circle",
                        title: "No Query Parameters",
                        subtitle: "This request doesn't contain any query parameters."
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    // MARK: - URL
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeaderView(title: "Full URL")
                        CodeBlockView(
                            title: nil,
                            content: viewModel.request.url,
                            maxLines: 3
                        )
                    }

                    // MARK: - Parameters Table
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeaderView(
                            title: "Parameters",
                            subtitle: "\(viewModel.request.queryParameters.count) parameters"
                        )

                        VStack(spacing: 0) {
                            // Header row
                            HStack {
                                Text("Key")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text("Value")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.quaternarySystemFill))

                            // Data rows
                            ForEach(viewModel.request.queryParameters) { param in
                                HStack(alignment: .top) {
                                    Text(param.key)
                                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                                        .foregroundStyle(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .textSelection(.enabled)

                                    Text(param.value)
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundStyle(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .textSelection(.enabled)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)

                                if param.id != viewModel.request.queryParameters.last?.id {
                                    Divider()
                                        .padding(.leading, 12)
                                }
                            }
                        }
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Preview

@available(iOS 16.0, *)
struct ParamsTabView_Previews: PreviewProvider {
    static var previews: some View {
        ParamsTabView(viewModel: RequestDetailViewModel(request: NetworkRequest(method: .get, url: "https://api.example.com/users?id=1", host: "api.example.com", path: "/users")))
    }
}
