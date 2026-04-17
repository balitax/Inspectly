//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import SwiftUI

// MARK: - Headers Tab View

struct HeadersTabView: View {
    @ObservedObject var viewModel: RequestDetailViewModel
    @State private var showingRequest = true

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
                    headersSection(headers: viewModel.request.requestHeaders, title: "Request Headers")
                } else {
                    headersSection(headers: viewModel.request.responseHeaders, title: "Response Headers")
                }
            }
            .padding(16)
        }
    }

    private func headersSection(headers: [RequestHeader], title: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
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
                        HStack(alignment: .top, spacing: 8) {
                            Text(header.key)
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundStyle(.accentColor)
                                .frame(minWidth: 100, alignment: .leading)

                            Text(header.value)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundStyle(.primary)
                                .textSelection(.enabled)
                                .lineLimit(3)

                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)

                        if header.id != headers.last?.id {
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
}

// MARK: - Preview

#Preview {
    HeadersTabView(viewModel: .mock())
}
