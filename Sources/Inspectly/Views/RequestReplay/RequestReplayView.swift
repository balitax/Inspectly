//
//  RequestReplayView.swift
//  Inspectly
//
//  Created by OpenCode on 26/09/2026.
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

// MARK: - Request Replay View

/// Replay a captured network request with optional editing.
/// The view lets developers inspect the original request, edit method/URL,
/// headers, and body, then execute a real network call and see the response.
struct RequestReplayView: View {
    @StateObject var viewModel: RequestReplayViewModel

    var body: some View {
        InspectlyNavigationStack {
            ZStack {
                List {
                    originalRequestSection
                    editRequestSection
                    headersSection
                    bodySection
                    resultSection
                }
                .listStyle(.insetGrouped)
                .padding(.bottom, 90)
                .navigationTitle("Replay Request")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Reset") {
                            viewModel.resetToOriginal()
                        }
                        .disabled(viewModel.isReplaying)
                    }
                }

                VStack {
                    Spacer()
                    replayButtonBar
                }
            }
        }
    }

    // MARK: - Sections

    private var originalRequestSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    HTTPMethodBadge(method: viewModel.originalRequest.method)
                    Text(viewModel.originalRequest.host)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                }

                Text(viewModel.originalRequest.url)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(.primary)
                    .lineLimit(3)

                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text(viewModel.originalRequest.timestamp, style: .date)
                        .font(.system(size: 12))
                    Text(viewModel.originalRequest.timestamp, style: .time)
                        .font(.system(size: 12))
                }
                .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        } header: {
            Text("Original Request")
        }
    }

    private var editRequestSection: some View {
        Section {
            HStack(spacing: 12) {
                Text("Method")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .frame(width: 60, alignment: .leading)

                Picker("Method", selection: $viewModel.method) {
                    ForEach(HTTPMethodType.allCases) { method in
                        Text(method.rawValue).tag(method)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
            }

            HStack(spacing: 12) {
                Text("URL")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .frame(width: 60, alignment: .leading)

                TextField("https://api.example.com/...", text: $viewModel.url)
                    .font(.system(size: 13, design: .monospaced))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
        } header: {
            Text("Edit Request")
        }
    }

    private var headersSection: some View {
        Section {
            ForEach($viewModel.headers) { $header in
                HStack(spacing: 8) {
                    TextField("Key", text: $header.key)
                        .font(.system(size: 13, design: .monospaced))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    Text("=")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)

                    TextField("Value", text: $header.value)
                        .font(.system(size: 13, design: .monospaced))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
            .onDelete(perform: viewModel.removeHeader)

            Button {
                viewModel.addHeader()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                    Text("Add Header")
                        .font(.system(size: 15))
                }
            }
        } header: {
            HStack {
                Text("Headers")
                Spacer()
                Text("\(viewModel.headers.count)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }

    private var bodySection: some View {
        Section {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.bodyText)
                    .font(.system(size: 13, design: .monospaced))
                    .frame(minHeight: 120)
                    .padding(4)
                    .disabled(viewModel.isReplaying)

                if viewModel.bodyText.isEmpty {
                    Text("Request body (optional)")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 12)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.separator), lineWidth: 1)
            )
        } header: {
            Text("Body")
        }
    }

    private var resultSection: some View {
        Group {
            if let errorMessage = viewModel.errorMessage {
                Section {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                        Spacer()
                    }
                } header: {
                    Text("Error")
                }
            }

            if let result = viewModel.result {
                Section {
                    HStack(spacing: 12) {
                        SettingsRow.icon("number", color: statusColor(for: result.statusCode))
                        Text("Status")
                            .font(.system(size: 15))
                        Spacer()
                        Text("\(result.statusCode)")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(statusColor(for: result.statusCode))
                    }

                    HStack(spacing: 12) {
                        SettingsRow.icon("clock", color: .orange)
                        Text("Duration")
                            .font(.system(size: 15))
                        Spacer()
                        Text(String(format: "%.0f ms", result.duration * 1000))
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(.orange)
                    }

                    ZStack(alignment: .topLeading) {
                        Text(result.body)
                            .font(.system(size: 13, design: .monospaced))
                            .padding(6)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                } header: {
                    Text("Response")
                }
            }
        }
    }

    private func statusColor(for code: Int) -> Color {
        switch code {
        case 200..<300: return .green
        case 400..<500: return .orange
        case 500..<600: return .red
        default: return .secondary
        }
    }

    // MARK: - Replay Button

    private var replayButtonBar: some View {
        Button {
            viewModel.replay()
        } label: {
            HStack(spacing: 10) {
                if viewModel.isReplaying {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "play.fill")
                }

                Text(viewModel.isReplaying ? "Replaying..." : "Replay Request")
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(viewModel.url.isEmpty ? Color.gray : Color.accentIndigo)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(viewModel.url.isEmpty || viewModel.isReplaying)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color(.systemBackground)
                .opacity(0.95)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Preview

struct RequestReplayView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleRequest = NetworkRequest(
            method: .post,
            url: "https://api.example.com/v1/users",
            host: "api.example.com",
            path: "/v1/users",
            statusCode: 201,
            requestHeaders: [
                RequestHeader(key: "Content-Type", value: "application/json"),
                RequestHeader(key: "Authorization", value: "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9")
            ],
            queryParameters: [],
            requestBody: RequestBody(
                rawString: "{\"name\":\"Agus\",\"email\":\"agus@example.com\"}",
                contentType: .json,
                size: 54
            ),
            responseBody: nil,
            timestamp: Date()
        )

        RequestReplayView(viewModel: RequestReplayViewModel(request: sampleRequest))
    }
}
