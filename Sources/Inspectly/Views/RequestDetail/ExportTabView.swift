//
//  ExportTabView.swift
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

// MARK: - Export Tab View

struct ExportTabView: View {
    @ObservedObject var viewModel: RequestDetailViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // MARK: - Quick Copy
                actionGroup(title: "Quick Copy", subtitle: "Copy to clipboard") {
                    exportButton(
                        title: "Copy as cURL",
                        subtitle: "Ready to paste in Terminal",
                        icon: "terminal",
                        color: .green
                    ) { viewModel.copyCURL() }

                    exportButton(
                        title: "Copy JSON Body",
                        subtitle: "Response body as formatted JSON",
                        icon: "curlybraces",
                        color: .blue
                    ) { viewModel.copyJSONBody() }

                    exportButton(
                        title: "Copy Full Request",
                        subtitle: "Headers, body, and response",
                        icon: "doc.on.doc",
                        color: .accentColor
                    ) { viewModel.copyFullRequest() }
                }

                // MARK: - Share
                actionGroup(title: "Share", subtitle: "Send via system share sheet") {
                    exportButton(
                        title: "Share Request",
                        subtitle: "cURL command via share sheet",
                        icon: "square.and.arrow.up",
                        color: .orange
                    ) { viewModel.shareRequest() }

                    exportButton(
                        title: "Share as JSON",
                        subtitle: "Export full request data as a file",
                        icon: "doc.text.fill",
                        color: .purple
                    ) { viewModel.shareAsJSON() }
                }

                // MARK: - Mocking
                actionGroup(title: "Mocking & Stubs", subtitle: "Create API mock from this request") {
                    exportButton(
                        title: "Create API Stub",
                        subtitle: "Convert this request into a mock",
                        icon: "hammer.fill",
                        color: .accentColor
                    ) { viewModel.createStub() }
                }

                // MARK: - cURL Preview
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeaderView(title: "cURL Preview")
                    CodeBlockView(
                        title: nil,
                        content: viewModel.request.curlCommand,
                        showCopyButton: true
                    )
                }
            }
            .padding(16)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Action Group

    private func actionGroup<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Group header inside the card
            HStack(spacing: 6) {
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .tracking(0.4)

                Text("·")
                    .foregroundStyle(.tertiary)

                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider().padding(.horizontal, 14)

            content()
        }
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Export Button

    private func exportButton(title: String, subtitle: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(color)
                    .frame(width: 34, height: 34)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.quaternary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

struct ExportTabView_Previews: PreviewProvider {
    static var previews: some View {
        ExportTabView(viewModel: .mock())
    }
}
