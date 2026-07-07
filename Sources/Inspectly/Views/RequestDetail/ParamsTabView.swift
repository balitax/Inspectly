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
    @State private var copiedParamId: UUID?

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
                    // MARK: - Full URL
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeaderView(title: "Full URL")
                        CodeBlockView(
                            title: nil,
                            content: viewModel.request.url,
                            maxLines: 3
                        )
                    }

                    // MARK: - Parameters
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeaderView(
                            title: "Parameters",
                            subtitle: "\(viewModel.request.queryParameters.count) found"
                        )

                        VStack(spacing: 0) {
                            ForEach(viewModel.request.queryParameters) { param in
                                paramRow(param)

                                if param.id != viewModel.request.queryParameters.last?.id {
                                    Divider().padding(.leading, 14)
                                }
                            }
                        }
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
            .padding(16)
        }
    }

    // MARK: - Param Row

    private func paramRow(_ param: QueryParameter) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Left accent line
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color.accentColor.opacity(0.6))
                .frame(width: 3)
                .padding(.vertical, 2)

            // Key + Value
            VStack(alignment: .leading, spacing: 4) {
                Text(param.key.uppercased())
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .tracking(0.4)

                Text(param.value.isEmpty ? "—" : param.value)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(param.value.isEmpty ? .tertiary : .primary)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            // Copy button
            Button {
                UIPasteboard.general.string = param.value
                withAnimation(.easeInOut(duration: 0.15)) { copiedParamId = param.id }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        if copiedParamId == param.id { copiedParamId = nil }
                    }
                }
            } label: {
                Image(systemName: copiedParamId == param.id ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 12))
                    .foregroundStyle(copiedParamId == param.id ? .green : .secondary)
                    .frame(width: 28, height: 28)
                    .background(Color(.quaternarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
    }
}

// MARK: - Preview

@available(iOS 16.0, *)
struct ParamsTabView_Previews: PreviewProvider {
    static var previews: some View {
        ParamsTabView(viewModel: RequestDetailViewModel(request: NetworkRequest(method: .get, url: "https://api.example.com/users?id=1", host: "api.example.com", path: "/users")))
    }
}
