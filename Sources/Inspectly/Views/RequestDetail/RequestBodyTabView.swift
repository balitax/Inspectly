//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import SwiftUI

// MARK: - Request Body Tab View

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

#Preview {
    RequestBodyTabView(viewModel: RequestDetailViewModel(request: NetworkRequest(method: .post, url: "https://api.example.com/login", host: "api.example.com", path: "/login")))
}
