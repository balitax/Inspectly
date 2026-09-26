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

/// Waterfall timeline of network requests with zoom, time axis, blocking
/// detection, and tap-to-detail navigation.
struct PerformanceTimelineView<Destination: View>: View {
    let requests: [NetworkRequest]
    let slowThreshold: TimeInterval
    @ViewBuilder let requestDetail: (NetworkRequest) -> Destination

    @State private var zoomScale: CGFloat = 1.0
    @State private var selectedRange: TimeRange = .all

    private let infoPanelWidth: CGFloat = 150
    private let rowHeight: CGFloat = 56

    init(
        requests: [NetworkRequest],
        slowThreshold: TimeInterval = 1.0,
        @ViewBuilder requestDetail: @escaping (NetworkRequest) -> Destination
    ) {
        self.requests = requests
        self.slowThreshold = slowThreshold
        self.requestDetail = requestDetail
    }

    private var filteredRequests: [NetworkRequest] {
        guard let duration = selectedRange.duration else { return requests }
        let latest = requests.map(\.timestamp).max() ?? Date()
        let cutoff = latest.addingTimeInterval(-duration)
        return requests.filter { $0.timestamp >= cutoff }
    }

    private var sortedRequests: [NetworkRequest] {
        filteredRequests.sorted { $0.timestamp < $1.timestamp }
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

    private var blockers: [UUID: NetworkRequest] {
        computeBlockers(for: sortedRequests)
    }

    var body: some View {
        VStack(spacing: 0) {
            controls
            timelineContent
        }
        .navigationTitle("Timeline")
    }

    // MARK: - Controls

    private var controls: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Text("Range")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)

                Picker("Range", selection: $selectedRange) {
                    ForEach(TimeRange.allCases) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 220)

                Spacer()
            }

            HStack(spacing: 10) {
                Text("Zoom")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)

                Slider(value: $zoomScale, in: 1.0...5.0, step: 0.5)
                    .tint(.accentColor)

                Text("\(String(format: "%.1fx", zoomScale))")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(width: 40)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
    }

    // MARK: - Timeline Content

    private var timelineContent: some View {
        GeometryReader { geometry in
            let baseTrackWidth = max(geometry.size.width - infoPanelWidth - 32, 200)
            let trackWidth = baseTrackWidth * zoomScale

            ScrollView(.vertical) {
                ScrollView(.horizontal) {
                    VStack(alignment: .leading, spacing: 0) {
                        timeAxisRow(trackWidth: trackWidth)

                        ForEach(sortedRequests) { request in
                                    InspectlyNavigationLink(destination: {
                                requestDetail(request)
                            }, label: {
                                timelineRow(for: request, trackWidth: trackWidth)
                                    .contentShape(Rectangle())
                            })
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Time Axis

    private func timeAxisRow(trackWidth: CGFloat) -> some View {
        HStack(spacing: 0) {
            Spacer()
                .frame(width: infoPanelWidth)

            ZStack(alignment: .leading) {
                Color(.quaternarySystemFill)
                    .frame(height: 1)
                    .offset(y: 12)

                ForEach(0..<6) { index in
                    let ratio = CGFloat(index) / 5.0
                    let x = ratio * trackWidth
                    let label = formatTime(ratio * totalDuration)

                    VStack(spacing: 2) {
                        Rectangle()
                            .fill(Color(.tertiaryLabel))
                            .frame(width: 1, height: 8)

                        Text(label)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    .offset(x: x)
                }
            }
            .frame(width: trackWidth, height: 32)
        }
    }

    // MARK: - Row

    private func timelineRow(for request: NetworkRequest, trackWidth: CGFloat) -> some View {
        HStack(spacing: 0) {
            infoPanel(for: request)
                .frame(width: infoPanelWidth, alignment: .leading)
                .padding(.trailing, 12)

            track(for: request, trackWidth: trackWidth)
                .frame(width: trackWidth, height: rowHeight)
        }
        .padding(.horizontal, 16)
        .frame(height: rowHeight)
        .background(Color(.secondarySystemBackground).opacity(0.3))
    }

    private func infoPanel(for request: NetworkRequest) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                HTTPMethodBadge(method: request.method)

                Text(request.shortURL)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
            }

            HStack(spacing: 6) {
                Text(request.formattedDuration)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(durationColor(for: request))

                if let blocker = blockers[request.id] {
                    Text("·")
                        .foregroundColor(.secondary)

                    Text("Blocked by \(blocker.shortURL)")
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                        .lineLimit(1)
                }
            }
        }
    }

    private func track(for request: NetworkRequest, trackWidth: CGFloat) -> some View {
        let startOffset = request.timestamp.timeIntervalSince(startTime) / totalDuration
        let durationRatio = (request.duration ?? 0) / totalDuration
        let barWidth = max(CGFloat(durationRatio) * trackWidth, 3)
        let offsetX = CGFloat(startOffset) * trackWidth

        return ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(.quaternarySystemFill))
                .frame(height: 4)

            RoundedRectangle(cornerRadius: 4)
                .fill(barColor(for: request))
                .frame(width: barWidth, height: 10)
                .offset(x: offsetX, y: -3)
        }
    }

    // MARK: - Helpers

    private func computeBlockers(for requests: [NetworkRequest]) -> [UUID: NetworkRequest] {
        var result: [UUID: NetworkRequest] = [:]
        for i in requests.indices {
            let current = requests[i]
            let currentStart = current.timestamp
            for j in (0..<i).reversed() {
                let candidate = requests[j]
                let candidateEnd = candidate.timestamp.addingTimeInterval(candidate.duration ?? 0)
                if candidateEnd > currentStart {
                    result[current.id] = candidate
                    break
                }
            }
        }
        return result
    }

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

    private func formatTime(_ interval: TimeInterval) -> String {
        if interval < 1 {
            return String(format: "%.0fms", interval * 1000)
        }
        return String(format: "%.1fs", interval)
    }
}

// MARK: - Time Range

private enum TimeRange: String, CaseIterable, Identifiable {
    case all = "All"
    case oneMinute = "1m"
    case fiveMinutes = "5m"
    case fifteenMinutes = "15m"

    var id: String { rawValue }

    var duration: TimeInterval? {
        switch self {
        case .all: return nil
        case .oneMinute: return 60
        case .fiveMinutes: return 300
        case .fifteenMinutes: return 900
        }
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
            PerformanceTimelineView(requests: requests) { request in
                Text("Detail for \(request.url)")
                    .navigationTitle(request.shortURL)
            }
        }
        .navigationViewStyle(.stack)
    }
}
