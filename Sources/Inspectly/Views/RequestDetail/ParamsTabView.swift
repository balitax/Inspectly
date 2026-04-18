//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import SwiftUI

// MARK: - Params Tab View

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
                                        .foregroundStyle(.accentColor)
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

#Preview {
    ParamsTabView(viewModel: RequestDetailViewModel(request: NetworkRequest(method: .get, url: "https://api.example.com/users?id=1", host: "api.example.com", path: "/users")))
}
