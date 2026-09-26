//
//  PerformanceTimelineView.swift
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

// MARK: - Performance Timeline View

/// UI prototype for a waterfall timeline of network requests.
/// Each request is drawn as a horizontal bar positioned by its start time
/// and sized by its duration, making slow or blocking requests easy to spot.
struct PerformanceTimelineView: View {
    let requests: [NetworkRequest]
    let slowThreshold: TimeInterval

    init(requests: [NetworkRequest], slowThreshold: TimeInterval = 1.0) {
        self.requests = requests
        self.slowThreshold = slowThreshold
    }

    private var sortedRequests: [NetworkRequest] {
        requests.sorted { $0.timestamp < $1.timestamp }
    }

    private var startTime: Date {
        sortedRequests.first?.timestamp ?? Date()
    }

    private var endTime: Date {
        sortedRequests.reduce(startTime) { latest, request in
            let end = request.timestamp.addingTimeInterval(request.duration ?? 0)
            return end > latest ? end : latest
        }
    }

    private var totalDuration: TimeInterval {
        max(endTime.timeIntervalSince(startTime), 0.001)
    }

    var body: some View {
        List(sortedRequests) { request in
            timelineRow(for: request)
        }
        .listStyle(.plain)
        .navigationTitle("Timeline")
    }

    // MARK: - Row

    private func timelineRow(for request: NetworkRequest) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                HTTPMethodBadge(method: request.method)

                Text(request.shortURL)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)

                Spacer()

                Text(request.formattedDuration)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(durationColor(for: request))
            }

            GeometryReader { geometry in
                let trackWidth = geometry.size.width
                let offsetRatio = request.timestamp.timeIntervalSince(startTime) / totalDuration
                let durationRatio = (request.duration ?? 0) / totalDuration
                let barWidth = max(CGFloat(durationRatio) * trackWidth, 4)
                let offsetX = CGFloat(offsetRatio) * trackWidth

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(.quaternarySystemFill))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(barColor(for: request))
                        .frame(width: barWidth, height: 8)
                        .offset(x: offsetX, y: -2)
                }
            }
            .frame(height: 10)
        }
        .padding(.vertical, 6)
    }

    // MARK: - Colors

    private func barColor(for request: NetworkRequest) -> Color {
        if request.isStubbed {
            return .accentIndigo
        }
        if let duration = request.duration, duration >= slowThreshold {
            return .orange
        }
        return Color.forStatusCode(request.statusCode)
    }

    private func durationColor(for request: NetworkRequest) -> Color {
        guard let duration = request.duration else { return .secondary }
        if duration >= slowThreshold * 3 { return .red }
        if duration >= slowThreshold { return .orange }
        return .secondary
    }
}

// MARK: - Preview

struct PerformanceTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        let base = Date()
        let requests: [NetworkRequest] = [
            NetworkRequest(
                method: .get,
                url: "https://api.example.com/config",
                host: "api.example.com",
                path: "/config",
                statusCode: 200,
                duration: 0.12,
                timestamp: base
            ),
            NetworkRequest(
                method: .get,
                url: "https://api.example.com/users",
                host: "api.example.com",
                path: "/users",
                statusCode: 200,
                duration: 0.85,
                timestamp: base.addingTimeInterval(0.15)
            ),
            NetworkRequest(
                method: .post,
                url: "https://api.example.com/login",
                host: "api.example.com",
                path: "/login",
                statusCode: 201,
                duration: 1.45,
                timestamp: base.addingTimeInterval(0.20)
            ),
            NetworkRequest(
                method: .get,
                url: "https://api.example.com/orders",
                host: "api.example.com",
                path: "/orders",
                statusCode: 500,
                duration: 2.10,
                timestamp: base.addingTimeInterval(0.40)
            ),
            NetworkRequest(
                method: .get,
                url: "https://api.example.com/products",
                host: "api.example.com",
                path: "/products",
                statusCode: 200,
                duration: 0.30,
                timestamp: base.addingTimeInterval(1.80)
            )
        ]

        NavigationView {
            PerformanceTimelineView(requests: requests)
        }
        .navigationViewStyle(.stack)
    }
}
