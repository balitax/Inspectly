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
                            Divider()
                        }
                    }
                }
                .sectionCardStyle()

                // MARK: - Tags
                if !viewModel.request.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)

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
                    }
                    .sectionCardStyle()
                }
            }
            // .padding(16)
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
                    .font(.system(size: 13, design: .default))
                    .foregroundStyle(.primary)
            }

            Spacer()
        }
        .padding(14)
        .background(Color.forStatusCode(viewModel.request.statusCode).opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: 0, style: .continuous)
                .strokeBorder(Color.forStatusCode(viewModel.request.statusCode).opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Overview Row

    private func overviewRow(label: String, value: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .frame(width: 28)

            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .frame(width: 90, alignment: .leading)

            Text(value)
                .font(.system(size: 13, design: label == "URL" || label == "Path" ? .monospaced : .default))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .textSelection(.enabled)

            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Flow Layout (for tags)

@available(iOS 16.0, *)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
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
        NavigationStack {
            OverviewTabView(viewModel: .mock())
        }
    }
}
