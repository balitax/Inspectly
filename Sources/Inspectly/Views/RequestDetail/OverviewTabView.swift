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
                .cornerRadius(12)

                // MARK: - Tags
                if !viewModel.request.tags.isEmpty {
                    tagsSection
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Status Banner

    private var statusBanner: some View {
        HStack(spacing: 14) {
            Image(systemName: viewModel.request.status.iconName)
                .font(.system(size: 28))
                .foregroundColor(Color.forStatusCode(viewModel.request.statusCode))

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
                    .foregroundColor(.primary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(14)
        .background(Color.forStatusCode(viewModel.request.statusCode).opacity(0.06))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.forStatusCode(viewModel.request.statusCode).opacity(0.18), lineWidth: 1)
        )
    }

    // MARK: - Overview Row

    private func overviewRow(label: String, value: String, icon: String) -> some View {
        let isCopyable = ["URL", "Path", "Host"].contains(label)

        return HStack(spacing: 12) {
            // Icon pill
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 30, height: 30)
                .background(Color(.quaternarySystemFill))
                .cornerRadius(8)

            // Label + value stack
            VStack(alignment: .leading, spacing: 3) {
                Text(label.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .tracking(0.4)

                Text(value)
                    .font(.system(size: 13, design: ["URL", "Path"].contains(label) ? .monospaced : .default))
                    .foregroundColor(.primary)
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
                        .foregroundColor(copiedLabel == label ? .green : .secondary)
                        .frame(width: 28, height: 28)
                        .background(Color(.quaternarySystemFill))
                        .cornerRadius(6)
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
                .foregroundColor(.secondary)
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
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 10)
        }
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Flow Layout (iOS 15 compatible)

struct FlowLayout: View {
    var spacing: CGFloat = 8
    var children: [AnyView]

    init<Content: View>(spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.children = ViewExtractor.extract(from: content())
    }

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(children.indices, id: \.self) { index in
                children[index]
                    .alignmentGuide(.leading, computeValue: { dimension in
                        if abs(width - dimension.width) > geometry.size.width {
                            width = 0
                            height -= dimension.height + spacing
                        }
                        let result = width
                        if index == children.count - 1 {
                            width = 0
                        } else {
                            width -= dimension.width + spacing
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        if index == children.count - 1 {
                            height = 0
                        }
                        return result
                    })
            }
        }
    }
}

// MARK: - View Extractor Helper

private enum ViewExtractor {
    static func extract<Content: View>(from view: Content) -> [AnyView] {
        var views: [AnyView] = []
        Mirror(reflecting: view).children.forEach { child in
            if let view = child.value as? AnyView {
                views.append(view)
            } else if let view = child.value as? (any View) {
                views.append(AnyView(view))
            }
        }
        return views.isEmpty ? [AnyView(view)] : views
    }
}

// MARK: - Preview

struct OverviewTabView_Previews: PreviewProvider {
    static var previews: some View {
        InspectlyNavigationStack {
            OverviewTabView(viewModel: .mock())
        }
    }
}
