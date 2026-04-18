//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import SwiftUI

// MARK: - Response Body Tab View

struct ResponseBodyTabView: View {
    @ObservedObject var viewModel: RequestDetailViewModel
    @State private var showRaw = false

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
                    // MARK: - Content Info
                    HStack {
                        Label(
                            viewModel.request.responseContentType.displayName,
                            systemImage: viewModel.request.responseContentType.iconName
                        )
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)

                        Spacer()

                        if let size = viewModel.request.responseBody?.formattedSize {
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

                    // MARK: - Status Bar
                    HStack(spacing: 8) {
                        StatusBadgeView(statusCode: viewModel.request.statusCode)
                        Text(viewModel.request.formattedDuration)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }

                    // MARK: - Body Content
                    CodeBlockView(
                        title: "Response Body",
                        content: showRaw
                            ? (viewModel.request.responseBody?.rawString ?? "")
                            : viewModel.prettyResponseBody
                    )
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Preview

#Preview {
    ResponseBodyTabView(viewModel: RequestDetailViewModel(request: NetworkRequest(method: .get, url: "https://api.example.com/users", host: "api.example.com", path: "/users")))
}
