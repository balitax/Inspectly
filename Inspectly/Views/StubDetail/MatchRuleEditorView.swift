//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import SwiftUI

// MARK: - Match Rule Editor View

struct MatchRuleEditorView: View {
    @ObservedObject var viewModel: StubDetailViewModel

    var body: some View {
        VStack(spacing: 14) {
            // MARK: - Method Picker
            VStack(alignment: .leading, spacing: 4) {
                Text("HTTP Method")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        methodChip("ANY", method: nil)
                        ForEach([HTTPMethodType.get, .post, .put, .patch, .delete]) { method in
                            methodChip(method.rawValue, method: method)
                        }
                    }
                }
            }

            Divider()

            // MARK: - URL Path
            VStack(alignment: .leading, spacing: 4) {
                Text("URL Path (contains)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                TextField("/api/v1/users", text: Binding(
                    get: { viewModel.stub.matchRule.urlPath ?? "" },
                    set: { viewModel.updateURLPath($0) }
                ))
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 13, design: .monospaced))
                .autocapitalization(.none)
                .autocorrectionDisabled()
            }

            // MARK: - Full URL
            VStack(alignment: .leading, spacing: 4) {
                Text("Full URL (exact match)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                TextField("https://api.example.com/v1/users", text: Binding(
                    get: { viewModel.stub.matchRule.fullURL ?? "" },
                    set: { viewModel.updateFullURL($0) }
                ))
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 13, design: .monospaced))
                .autocapitalization(.none)
                .autocorrectionDisabled()
            }

            Divider()

            // MARK: - Query Parameters
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Query Parameters")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        viewModel.addMatchQueryParam()
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 14))
                    }
                }

                ForEach(Array(viewModel.stub.matchRule.queryParameters.enumerated()), id: \.element.id) { index, _ in
                    HStack(spacing: 6) {
                        TextField("Key", text: $viewModel.stub.matchRule.queryParameters[index].key)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 12, design: .monospaced))

                        TextField("Value", text: $viewModel.stub.matchRule.queryParameters[index].value)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 12, design: .monospaced))

                        Button {
                            viewModel.removeMatchQueryParam(at: index)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                                .font(.system(size: 16))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Divider()

            // MARK: - Headers
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Headers")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        viewModel.addMatchHeader()
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 14))
                    }
                }

                ForEach(Array(viewModel.stub.matchRule.headers.enumerated()), id: \.element.id) { index, _ in
                    HStack(spacing: 6) {
                        TextField("Key", text: $viewModel.stub.matchRule.headers[index].key)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 12, design: .monospaced))

                        TextField("Value", text: $viewModel.stub.matchRule.headers[index].value)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 12, design: .monospaced))

                        Button {
                            viewModel.removeMatchHeader(at: index)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                                .font(.system(size: 16))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Divider()

            // MARK: - Body Contains
            VStack(alignment: .leading, spacing: 4) {
                Text("Body Contains")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                TextField("Search string in body", text: Binding(
                    get: { viewModel.stub.matchRule.bodyContains ?? "" },
                    set: { viewModel.updateBodyContains($0) }
                ))
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 13, design: .monospaced))
            }
        }
    }

    // MARK: - Method Chip

    private func methodChip(_ label: String, method: HTTPMethodType?) -> some View {
        let isSelected = viewModel.stub.matchRule.method == method
        return Button {
            viewModel.updateMethod(method)
        } label: {
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(isSelected ? Color.accentColor.opacity(0.15) : Color(.tertiarySystemFill))
                .foregroundStyle(isSelected ? .accentColor : .secondary)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        MatchRuleEditorView(viewModel: .mock())
            .padding()
    }
}
