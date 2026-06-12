//
//  DemoAppView.swift
//  InspectlyDemo
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
import Alamofire
import Inspectly

struct DemoAppView: View {

    // MARK: - Network Engine

    private enum NetworkEngine: String, CaseIterable, Identifiable {
        case alamofire = "Alamofire"
        case urlSession = "URLSession"
        var id: String { rawValue }
    }

    // MARK: - State

    @State private var responseText: String? = nil
    @State private var isLoading = false
    @State private var selectedNetworkEngine: NetworkEngine = .alamofire
    @State private var lastRequestName: String = ""
    @State private var requestFailed = false
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    // MARK: - Body

    var body: some View {
        InspectlyNavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerCard
                    enginePicker
                    actionsGrid
                    if isLoading || responseText != nil {
                        responseConsole
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Inspectly Demo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isDarkMode.toggle() }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .foregroundStyle(.primary)
                    }
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.345, green: 0.337, blue: 0.839),
                                Color(red: 0.188, green: 0.690, blue: 0.780)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Inspectly")
                    .font(.system(size: 18, weight: .bold))

                Text("Shake ⌘+Ctrl+Z to open inspector")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Engine Picker

    private var enginePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Network Engine", systemImage: "network")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)

            Picker("Network Engine", selection: $selectedNetworkEngine) {
                ForEach(NetworkEngine.allCases) { engine in
                    Text(engine.rawValue).tag(engine)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Actions Grid

    private var actionsGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Quick Actions", systemImage: "bolt.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                actionCard(
                    title: "Fetch Comments",
                    subtitle: "GET /comments",
                    icon: "message.circle.fill",
                    color: Color(red: 0.345, green: 0.337, blue: 0.839),
                    action: loadCommentList
                )
                actionCard(
                    title: "Fetch Post",
                    subtitle: "GET /posts/1",
                    icon: "doc.text.fill",
                    color: .teal,
                    action: loadPostDetail
                )
                actionCard(
                    title: "404 Error",
                    subtitle: "Simulate not found",
                    icon: "exclamationmark.triangle.fill",
                    color: .orange,
                    action: loadInvalidEndpoint
                )
                actionCard(
                    title: "503 Error",
                    subtitle: "HTML response body",
                    icon: "server.rack",
                    color: .red,
                    action: load503Error
                )
                actionCard(
                    title: "Create Post",
                    subtitle: "POST /posts",
                    icon: "plus.circle.fill",
                    color: .purple,
                    action: createPost
                )
            }
        }
    }

    private func actionCard(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
                    .frame(width: 36, height: 36)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .opacity(isLoading ? 0.5 : 1)
    }

    // MARK: - Response Console

    private var responseConsole: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Response", systemImage: "terminal.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                if !isLoading, responseText != nil {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(requestFailed ? Color.red : Color.green)
                            .frame(width: 6, height: 6)
                        Text(requestFailed ? "Failed" : "Success")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(requestFailed ? .red : .green)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((requestFailed ? Color.red : Color.green).opacity(0.1))
                    .clipShape(Capsule())
                }

                if !isLoading, responseText != nil {
                    Text(lastRequestName)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 4)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.systemBackground))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                    }

                if isLoading {
                    HStack(spacing: 10) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Sending request via \(selectedNetworkEngine.rawValue)...")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                } else if let text = responseText {
                    ScrollView(.vertical) {
                        Text(text)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                    }
                    .frame(maxHeight: 240)
                }
            }
        }
    }

    // MARK: - Network Actions

    private func loadCommentList() {
        fire("Comments", url: "https://api.bareksa.dev/internal/v1/sbn-homepage/seri?year=2026")
    }

    private func loadPostDetail() {
        fire("Post Detail", url: "https://jsonplaceholder.typicode.com/posts/1")
    }

    private func loadInvalidEndpoint() {
        fire("404 Error", url: "https://jsonplaceholder.typicode.com/invalid-endpoint-404")
    }

    private func load503Error() {
        fire("503 Error", url: "https://mock-api.net/api/inspectly/error-503")
    }

    private func createPost() {
        fire("Create Post", url: "https://jsonplaceholder.typicode.com/posts", method: .post)
    }

    private func fire(_ name: String, url: String, method: HTTPMethod = .get) {
        isLoading = true
        requestFailed = false
        lastRequestName = name
        responseText = nil

        switch selectedNetworkEngine {
        case .alamofire: performAlamofireRequest(from: url, method: method)
        case .urlSession: performURLSessionRequest(from: url, method: method)
        }
    }

    // MARK: - Alamofire

    private func performAlamofireRequest(from urlString: String, method: HTTPMethod) {
        let params: [String: Any]? = method == .post ? ["title": "foo", "body": "bar", "userId": 1] : nil

        AF.request(urlString, method: method, parameters: params, encoding: JSONEncoding.default,
                   headers: ["Accept": "application/json"])
            .validate()
            .responseData { response in
                isLoading = false
                switch response.result {
                case .success(let data):
                    responseText = String(data: data, encoding: .utf8)?.prettyPrintedJSON
                        ?? String(data: data, encoding: .utf8)
                        ?? "Unable to parse response"
                case .failure(let error):
                    requestFailed = true
                    let code = response.response?.statusCode ?? 0
                    let body = response.data.flatMap { String(data: $0, encoding: .utf8) } ?? "No body"
                    responseText = "Status: \(code)\nError: \(error.localizedDescription)\n\nBody:\n\(body)"
                }
            }
    }

    // MARK: - URLSession

    private func performURLSessionRequest(from urlString: String, method: HTTPMethod) {
        guard let url = URL(string: urlString) else {
            isLoading = false
            responseText = "Invalid URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if method == .post {
            request.httpBody = try? JSONSerialization.data(
                withJSONObject: ["title": "foo", "body": "bar", "userId": 1]
            )
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error {
                    requestFailed = true
                    responseText = "Error: \(error.localizedDescription)"
                    return
                }
                guard let data else {
                    requestFailed = true
                    responseText = "No data received"
                    return
                }
                let code = (response as? HTTPURLResponse)?.statusCode ?? 0
                if code >= 400 { requestFailed = true }
                responseText = String(data: data, encoding: .utf8)?.prettyPrintedJSON
                    ?? String(data: data, encoding: .utf8)
                    ?? "Unable to parse response"
            }
        }.resume()
    }
}

// MARK: - Preview

struct DemoAppView_Previews: PreviewProvider {
    static var previews: some View {
        DemoAppView()
        DemoAppView()
            .preferredColorScheme(.dark)
    }
}

// MARK: - JSON Formatter

extension String {
    var prettyPrintedJSON: String? {
        guard
            let data = data(using: .utf8),
            let jsonObject = try? JSONSerialization.jsonObject(with: data),
            let prettyData = try? JSONSerialization.data(
                withJSONObject: jsonObject,
                options: [.prettyPrinted, .sortedKeys]
            )
        else { return nil }
        return String(decoding: prettyData, as: UTF8.self)
    }
}
