//
//  HeadersTabView.swift
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

// MARK: - Headers Tab View

@available(iOS 16.0, *)
struct HeadersTabView: View {
    @ObservedObject var viewModel: RequestDetailViewModel
    @State private var showingRequest = true
    @State private var copiedHeaderId: UUID?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // MARK: - Toggle
                Picker("Headers", selection: $showingRequest) {
                    Text("Request (\(viewModel.request.requestHeaders.count))").tag(true)
                    Text("Response (\(viewModel.request.responseHeaders.count))").tag(false)
                }
                .pickerStyle(.segmented)

                // MARK: - Headers List
                if showingRequest {
                    headersSection(headers: viewModel.request.requestHeaders)
                } else {
                    headersSection(headers: viewModel.request.responseHeaders)
                }
            }
            .padding(16)
        }
    }

    // MARK: - Headers Section

    @available(iOS 16.0, *)
    @ViewBuilder
    private func headersSection(headers: [RequestHeader]) -> some View {
        if headers.isEmpty {
            EmptyStateView(
                icon: "list.bullet.rectangle",
                title: "No Headers",
                subtitle: "No \(showingRequest ? "request" : "response") headers captured."
            )
            .frame(height: 200)
        } else {
            VStack(spacing: 0) {
                ForEach(headers) { header in
                    headerRow(header)

                    if header.id != headers.last?.id {
                        Divider()
                            .padding(.leading, 14)
                    }
                }
            }
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    // MARK: - Header Row

    @available(iOS 16.0, *)
    private func headerRow(_ header: RequestHeader) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Left accent line
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(accentColor(for: header.key))
                .frame(width: 3)
                .padding(.vertical, 2)

            // Key + Value stack
            VStack(alignment: .leading, spacing: 4) {
                Text(header.key.uppercased())
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .tracking(0.4)

                Text(header.formattedValue)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)

                if header.formattedValue != header.value {
                    Text(header.value)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.tertiary)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 8)

            // Copy button
            Button {
                UIPasteboard.general.string = header.value
                withAnimation(.easeInOut(duration: 0.15)) {
                    copiedHeaderId = header.id
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        if copiedHeaderId == header.id { copiedHeaderId = nil }
                    }
                }
            } label: {
                Image(systemName: copiedHeaderId == header.id ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 12))
                    .foregroundStyle(copiedHeaderId == header.id ? .green : .secondary)
                    .frame(width: 28, height: 28)
                    .background(Color(.quaternarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
    }

    // MARK: - Accent Color by Header Category

    private func accentColor(for key: String) -> Color {
        switch key.lowercased() {
        case "authorization", "x-api-key", "api-key", "x-auth-token",
             "cookie", "set-cookie":
            return .orange
        case "content-type", "accept", "content-encoding", "accept-encoding",
             "transfer-encoding":
            return .blue
        case "cache-control", "etag", "if-none-match", "last-modified",
             "expires":
            return .purple
        case "x-request-id", "x-trace-id", "x-correlation-id",
             "request-id", "traceparent":
            return .teal
        case "content-length", "content-range":
            return .indigo
        default:
            return Color(.quaternaryLabel)
        }
    }
}

// MARK: - Preview

@available(iOS 16.0, *)
struct HeadersTabView_Previews: PreviewProvider {
    static var previews: some View {
        HeadersTabView(viewModel: .mock())
    }
}
