//
//  ResponseEditorView.swift
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

// MARK: - Response Editor View

struct ResponseEditorView: View {
    @ObservedObject var viewModel: StubDetailViewModel

    var body: some View {
        VStack(spacing: 14) {
            statusCodeSection
            Divider()
            responseDelaySection
            Divider()
            jsonBodySection
        }
    }

    private let quickStatusCodes = [200, 201, 204, 400, 401, 403, 404, 422, 500, 502, 503]

    private var statusCodeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Status Code")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                TextField("200", value: $viewModel.response.statusCode, formatter: NumberFormatter())
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 14, design: .monospaced))
                    .frame(width: 80)
                    .keyboardType(.numberPad)

                StatusBadgeView(statusCode: viewModel.response.statusCode)

                Spacer()
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(quickStatusCodes, id: \.self) { code in
                    Button {
                        viewModel.response.statusCode = code
                    } label: {
                        Text("\(code)")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(viewModel.response.statusCode == code ? Color.accentColor.opacity(0.15) : Color(.tertiarySystemFill))
                            .foregroundColor(viewModel.response.statusCode == code ? .accentColor : .secondary)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var responseDelaySection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Response Delay")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "%.1fs", viewModel.response.responseDelay))
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.accentColor)
            }

            Slider(value: $viewModel.response.responseDelay, in: 0...30, step: 0.5)
                .tint(.accentColor)
        }
    }

    private var jsonBodySection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("JSON Response Body")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)

                Spacer()

                if let error = viewModel.jsonValidationError {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.red)
                } else if viewModel.response.jsonBody?.isEmpty == false {
                    Label("Valid", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.green)
                }
            }

            TextEditor(text: Binding(
                get: { viewModel.response.jsonBody ?? "" },
                set: { viewModel.response.jsonBody = $0.isEmpty ? nil : $0 }
            ))
            .font(.system(size: 12, design: .monospaced))
            .frame(minHeight: 150)
            .padding(4)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(8)
            .onChange(of: viewModel.response.jsonBody) { _ in
                viewModel.validateJSON()
            }
        }
    }
}

// MARK: - Preview

struct ResponseEditorView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            ResponseEditorView(viewModel: .mock())
                .padding()
        }
    }
}
