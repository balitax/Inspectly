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

@available(iOS 16.0, *)
struct RequestRowView: View {
    let request: NetworkRequest

    var body: some View {
        HStack(spacing: 10) {
            // Method badge
            HTTPMethodBadge(method: request.method)

            // Request info
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    Text(request.shortURL)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    if request.isStubbed {
                        Image(systemName: "hammer.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.accentColor)
                            .padding(3)
                            .background(Color.accentColor.opacity(0.12))
                            .clipShape(Circle())
                    }
                }

                HStack(spacing: 8) {
                    Text(request.host)
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)

                    Text("·")
                        .foregroundStyle(.quaternary)

                    Text(request.timestamp.relativeTimeString)
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            // Right side indicators
            VStack(alignment: .trailing, spacing: 4) {
                StatusBadgeView(statusCode: request.statusCode)

                HStack(spacing: 6) {
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

                    Text(request.formattedDuration)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(durationColor)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var durationColor: Color {
        guard let duration = request.duration else { return .secondary }
        if duration > 3.0 { return .red }
        if duration > 1.0 { return .orange }
        return .secondary
    }
}

// MARK: - Preview

@available(iOS 16.0, *)
struct RequestRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            RequestRowView(request: NetworkRequest(method: .get, url: "https://api.example.com/users", host: "api.example.com", path: "/users", statusCode: 200))
            RequestRowView(request: NetworkRequest(method: .post, url: "https://api.example.com/login", host: "api.example.com", path: "/login", statusCode: 201))
            RequestRowView(request: NetworkRequest(method: .get, url: "https://api.example.com/error", host: "api.example.com", path: "/error", statusCode: 500))
        }
        .listStyle(.insetGrouped)
    }
}
