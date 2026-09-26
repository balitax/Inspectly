//
//  RequestReplayViewModel.swift
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

import Foundation
import SwiftUI

// MARK: - Replay Result

struct ReplayResult {
    let statusCode: Int
    let headers: [RequestHeader]
    let body: String
    let duration: TimeInterval
}

// MARK: - Request Replay View Model

@MainActor
final class RequestReplayViewModel: ObservableObject {
    @Published var method: HTTPMethodType
    @Published var url: String
    @Published var headers: [RequestHeader]
    @Published var bodyText: String
    @Published var isReplaying: Bool = false
    @Published var result: ReplayResult?
    @Published var errorMessage: String?

    let originalRequest: NetworkRequest

    init(request: NetworkRequest) {
        self.originalRequest = request
        self.method = request.method
        self.url = request.url
        self.headers = request.requestHeaders
        self.bodyText = request.requestBody?.rawString ?? ""
    }

    func addHeader() {
        headers.append(RequestHeader(key: "", value: ""))
    }

    func removeHeader(at offsets: IndexSet) {
        headers.remove(atOffsets: offsets)
    }

    func resetToOriginal() {
        method = originalRequest.method
        url = originalRequest.url
        headers = originalRequest.requestHeaders
        bodyText = originalRequest.requestBody?.rawString ?? ""
        result = nil
        errorMessage = nil
    }

    func replay() {
        guard !isReplaying, !url.isEmpty else { return }

        isReplaying = true
        result = nil
        errorMessage = nil

        Task {
            do {
                let output = try await executeReplay()
                result = output
            } catch {
                errorMessage = error.localizedDescription
            }
            isReplaying = false
        }
    }

    // MARK: - Private

    private func executeReplay() async throws -> ReplayResult {
        guard let targetURL = URL(string: url), targetURL.scheme != nil else {
            throw ReplayError.invalidURL
        }

        var request = URLRequest(url: targetURL)
        request.httpMethod = method.rawValue
        request.timeoutInterval = 30

        for header in headers where !header.key.isEmpty {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }

        if !bodyText.isEmpty, method.allowsBody {
            request.httpBody = bodyText.data(using: .utf8)
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }

        let start = Date()
        let (data, response) = try await URLSession.shared.data(for: request)
        let duration = Date().timeIntervalSince(start)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ReplayError.invalidResponse
        }

        let responseHeaders = httpResponse.allHeaderFields.map { key, value in
            RequestHeader(key: "\(key)", value: "\(value)")
        }

        let rawString = String(data: data, encoding: .utf8) ?? ""
        let bodyString: String
        if data.isEmpty {
            bodyString = "<empty response>"
        } else if let pretty = rawString.prettyPrintedJSON {
            bodyString = pretty
        } else if !rawString.isEmpty {
            bodyString = rawString
        } else {
            bodyString = "<binary data: \(data.count) bytes>"
        }

        return ReplayResult(
            statusCode: httpResponse.statusCode,
            headers: responseHeaders,
            body: bodyString,
            duration: duration
        )
    }
}

// MARK: - Replay Errors

enum ReplayError: LocalizedError {
    case invalidURL
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .invalidResponse:
            return "The server returned an unexpected response."
        }
    }
}

// MARK: - HTTP Method Body Support

private extension HTTPMethodType {
    var allowsBody: Bool {
        switch self {
        case .get, .head, .delete, .options:
            return false
        case .post, .put, .patch:
            return true
        }
    }
}
