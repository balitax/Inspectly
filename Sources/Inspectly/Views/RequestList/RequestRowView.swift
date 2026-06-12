//
//  RequestRowView.swift
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

// MARK: - Request Row View

struct RequestRowView: View {
    let request: NetworkRequest
    var slowThreshold: TimeInterval = 1.0

    var body: some View {
        HStack(spacing: 10) {
            // Left status accent line
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(statusAccentColor)
                .frame(width: 3)
                .padding(.vertical, 2)

            // Method badge
            HTTPMethodBadge(method: request.method)

            // Main content
            VStack(alignment: .leading, spacing: 4) {
                // Line 1: URL path + stub indicator
                HStack(spacing: 6) {
                    Text(request.shortURL)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    if request.isStubbed {
                        Image(systemName: "hammer.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(.accentColor)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    }
                }

                // Line 2: host · timestamp · indicators
                HStack(spacing: 5) {
                    if !request.host.isEmpty {
                        Text(request.host)
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)

                        Text("·")
                            .font(.system(size: 11))
                            .foregroundStyle(.quaternary)
                    }

                    Text(request.timestamp.relativeTimeString)
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)

                    if request.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.orange)
                    }

                    if request.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.pink)
                    }

                    if isLargeResponse {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.orange)
                    }
                }
            }

            Spacer(minLength: 6)

            // Right: status badge + duration
            VStack(alignment: .trailing, spacing: 5) {
                StatusBadgeView(statusCode: request.statusCode)

                HStack(spacing: 4) {
                    if isSlow {
                        Image(systemName: "tortoise.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.orange)
                    }
                    Text(request.formattedDuration)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(durationColor)
                }
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: - Computed Colors

    private var statusAccentColor: Color {
        guard let code = request.statusCode else {
            return request.status == .timeout || request.status == .noInternet
                ? .red : Color(.quaternaryLabel)
        }
        return Color.forStatusCode(code)
    }

    private var isSlow: Bool {
        guard let duration = request.duration else { return false }
        return duration >= slowThreshold
    }

    private var isLargeResponse: Bool {
        (request.responseBody?.size ?? 0) >= 1_048_576
    }

    private var durationColor: Color {
        guard let duration = request.duration else { return .secondary }
        if duration >= slowThreshold * 3 { return .red }
        if duration >= slowThreshold { return .orange }
        return .secondary
    }
}

// MARK: - Preview

struct RequestRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            RequestRowView(request: NetworkRequest(method: .get, url: "https://api.example.com/users", host: "api.example.com", path: "/users", statusCode: 200))
            RequestRowView(request: NetworkRequest(method: .post, url: "https://api.example.com/login", host: "api.example.com", path: "/login", statusCode: 201))
            RequestRowView(request: NetworkRequest(method: .delete, url: "https://api.example.com/users/1", host: "api.example.com", path: "/users/1", statusCode: 404))
            RequestRowView(request: NetworkRequest(method: .get, url: "https://api.example.com/error", host: "api.example.com", path: "/error", statusCode: 500))
        }
        .listStyle(.insetGrouped)
    }
}
