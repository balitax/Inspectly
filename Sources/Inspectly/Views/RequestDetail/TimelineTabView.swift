//
//  TimelineTabView.swift
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

// MARK: - Timeline Tab View

@available(iOS 16.0, *)
struct TimelineTabView: View {
    @ObservedObject var viewModel: RequestDetailViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.request.timelineEvents.isEmpty {
                    EmptyStateView(
                        icon: "clock.arrow.circlepath",
                        title: "No Timeline Data",
                        subtitle: "Timeline events are captured during live network interception."
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    // MARK: - Total Duration
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Total Duration")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                            Text(viewModel.request.formattedDuration)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                        }
                        Spacer()

                        Image(systemName: "clock.fill")
                            .font(.system(size: 32))
                            .foregroundColor(Color.accentColor.opacity(0.3))
                    }
                    .sectionCardStyle()

                    // MARK: - Timeline Events
                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.request.timelineEvents.enumerated()), id: \.element.id) { index, event in
                            timelineRow(
                                event: event,
                                isFirst: index == 0,
                                isLast: index == viewModel.request.timelineEvents.count - 1,
                                totalDuration: viewModel.request.duration ?? 1
                            )
                        }
                    }
                    .sectionCardStyle()
                }
            }
            .padding(16)
        }
    }

    // MARK: - Timeline Row

    private func timelineRow(event: TimelineEvent, isFirst: Bool, isLast: Bool, totalDuration: TimeInterval) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Timeline indicator
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(Color.accentColor.opacity(0.3))
                        .frame(width: 2, height: 12)
                }

                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 10, height: 10)

                if !isLast {
                    Rectangle()
                        .fill(Color.accentColor.opacity(0.3))
                        .frame(width: 2)
                        .frame(minHeight: 30)
                }
            }
            .frame(width: 10)

            // Event info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(event.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)

                    Spacer()

                    if let duration = event.duration {
                        Text(formatDuration(duration))
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }

                if let detail = event.detail {
                    Text(detail)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                // Duration bar
                if let duration = event.duration {
                    GeometryReader { geo in
                        let width = geo.size.width * CGFloat(duration / totalDuration)
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(Color.accentColor.opacity(0.2))
                            .frame(width: max(width, 4), height: 4)
                    }
                    .frame(height: 4)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        if duration < 0.001 {
            return String(format: "%.0fµs", duration * 1_000_000)
        } else if duration < 1 {
            return String(format: "%.1fms", duration * 1000)
        } else {
            return String(format: "%.2fs", duration)
        }
    }
}

// MARK: - Preview

@available(iOS 16.0, *)
struct TimelineTabView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineTabView(viewModel: RequestDetailViewModel(request: NetworkRequest(method: .get, url: "https://api.example.com/users", host: "api.example.com", path: "/users")))
    }
}
