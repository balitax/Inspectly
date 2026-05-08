//
//  OverviewTabView.swift
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

// MARK: - Overview Tab View

@available(iOS 16.0, *)
struct OverviewTabView: View {
    @ObservedObject var viewModel: RequestDetailViewModel
    @State private var copiedLabel: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // MARK: - Status Banner
                statusBanner

                // MARK: - Request Info
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.overviewItems.enumerated()), id: \.offset) { index, item in
                        overviewRow(label: item.label, value: item.value, icon: item.icon)
                        if index < viewModel.overviewItems.count - 1 {
                            Divider().padding(.leading, 54)
                        }
                    }
                }
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                // MARK: - Tags
                if !viewModel.request.tags.isEmpty {
                    tagsSection
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Status Banner

    private var statusBanner: some View {
        HStack(spacing: 14) {
            Image(systemName: viewModel.request.status.iconName)
                .font(.system(size: 28))
                .foregroundStyle(Color.forStatusCode(viewModel.request.statusCode))
                .symbolRenderingMode(.hierarchical)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    HTTPMethodBadge(method: viewModel.request.method)
                    StatusBadgeView(statusCode: viewModel.request.statusCode)

                    if viewModel.request.isStubbed {
                        Text("STUBBED")
                            .badgeStyle(color: .accentColor, isSmall: true)
                    }
                }

                Text(viewModel.request.url)
                    .font(.system(size: 13))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(14)
        .background(Color.forStatusCode(viewModel.request.statusCode).opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.forStatusCode(viewModel.request.statusCode).opacity(0.18), lineWidth: 1)
        )
    }

    // MARK: - Overview Row

    private func overviewRow(label: String, value: String, icon: String) -> some View {
        let isCopyable = ["URL", "Path", "Host"].contains(label)

        return HStack(spacing: 12) {
            // Icon pill
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 30, height: 30)
                .background(Color(.quaternarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            // Label + value stack
            VStack(alignment: .leading, spacing: 3) {
                Text(label.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .tracking(0.4)

                Text(value)
                    .font(.system(size: 13, design: ["URL", "Path"].contains(label) ? .monospaced : .default))
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            // Copy button for URL / Path / Host
            if isCopyable {
                Button {
                    UIPasteboard.general.string = value
                    withAnimation(.easeInOut(duration: 0.15)) { copiedLabel = label }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            if copiedLabel == label { copiedLabel = nil }
                        }
                    }
                } label: {
                    Image(systemName: copiedLabel == label ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 12))
                        .foregroundStyle(copiedLabel == label ? .green : .secondary)
                        .frame(width: 28, height: 28)
                        .background(Color(.quaternarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
    }

    // MARK: - Tags Section

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TAGS")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
                .tracking(0.4)
                .padding(.horizontal, 14)

            FlowLayout(spacing: 6) {
                ForEach(viewModel.request.tags) { tag in
                    Text(tag.name)
                        .font(.system(size: 11, weight: .medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.12))
                        .foregroundColor(.accentColor)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 10)
        }
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Flow Layout (for tags)

@available(iOS 16.0, *)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxHeight = max(maxHeight, y + rowHeight)
        }

        return (positions, CGSize(width: maxWidth, height: maxHeight))
    }
}

// MARK: - Preview

@available(iOS 16.0, *)
struct OverviewTabView_Previews: PreviewProvider {
    static var previews: some View {
        InspectlyNavigationStack {
            OverviewTabView(viewModel: .mock())
        }
    }
}
