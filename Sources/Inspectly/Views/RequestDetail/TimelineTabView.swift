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
                    // MARK: - Total Duration Card
                    totalDurationCard

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
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding(16)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Total Duration Card

    private var totalDurationCard: some View {
        HStack(spacing: 14) {
            // Icon pill
            Image(systemName: "clock.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 40, height: 40)
                .background(Color(.quaternarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text("TOTAL DURATION")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .tracking(0.4)

                Text(viewModel.request.formattedDuration)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            }

            Spacer()

            // Event count pill
            Text("\(viewModel.request.timelineEvents.count) events")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(.quaternarySystemFill))
                .clipShape(Capsule())
        }
        .padding(14)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Timeline Row

    private func timelineRow(event: TimelineEvent, isFirst: Bool, isLast: Bool, totalDuration: TimeInterval) -> some View {
        HStack(alignment: .top, spacing: 14) {
            // Dot + connecting line
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(Color.accentColor.opacity(0.25))
                        .frame(width: 2, height: 10)
                }

                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 10, height: 10)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.accentColor.opacity(0.3), lineWidth: 3)
                    )

                if !isLast {
                    Rectangle()
                        .fill(Color.accentColor.opacity(0.25))
                        .frame(width: 2)
                        .frame(minHeight: 36)
                }
            }
            .frame(width: 10)
            .padding(.top, 10)

            // Event info
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .center) {
                    Text(event.name.uppercased())
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .tracking(0.4)

                    Spacer()

                    if let duration = event.duration {
                        Text(formatDuration(duration))
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(.quaternarySystemFill))
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                }

                if let detail = event.detail {
                    Text(detail)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(.secondary)
                }

                // Duration bar
                if let duration = event.duration, totalDuration > 0 {
                    GeometryReader { geo in
                        let width = geo.size.width * CGFloat(duration / totalDuration)
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(Color(.quaternarySystemFill))
                                .frame(height: 5)
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(Color.accentColor.opacity(0.5))
                                .frame(width: max(width, 4), height: 5)
                        }
                    }
                    .frame(height: 5)
                }
            }
            .padding(.vertical, 10)
            .padding(.trailing, 14)
        }
        .padding(.leading, 14)

        // No extra divider — the connecting lines serve as separators
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

struct TimelineTabView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineTabView(viewModel: RequestDetailViewModel(request: NetworkRequest(method: .get, url: "https://api.example.com/users", host: "api.example.com", path: "/users")))
    }
}
