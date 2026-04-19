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

@available(iOS 16.0, *)
struct ExportTabView: View {
    @ObservedObject var viewModel: RequestDetailViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // MARK: - Quick Copy Section
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeaderView(title: "Quick Copy")

                    VStack(spacing: 8) {
                        exportButton(
                            title: "Copy as cURL",
                            subtitle: "Ready to paste in Terminal",
                            icon: "terminal",
                            color: .green
                        ) {
                            viewModel.copyCURL()
                        }

                        exportButton(
                            title: "Copy JSON Body",
                            subtitle: "Response body as formatted JSON",
                            icon: "curlybraces",
                            color: .blue
                        ) {
                            viewModel.copyJSONBody()
                        }

                        exportButton(
                            title: "Copy Full Request",
                            subtitle: "Headers, body, and response",
                            icon: "doc.on.doc",
                            color: .accentColor
                        ) {
                            viewModel.copyFullRequest()
                        }
                    }
                }

                Divider()

                // MARK: - Share Section
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeaderView(title: "Share")

                    exportButton(
                        title: "Share Request",
                        subtitle: "Share via system share sheet (cURL)",
                        icon: "square.and.arrow.up",
                        color: .orange
                    ) {
                        viewModel.shareRequest()
                    }

                    exportButton(
                        title: "Share as JSON file",
                        subtitle: "Export full request data as a file",
                        icon: "doc.text.fill",
                        color: .purple
                    ) {
                        viewModel.shareAsJSON()
                    }
                }

                Divider()

                // MARK: - Mocking Section
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeaderView(title: "Mocking & Stubs")

                    exportButton(
                        title: "Create API Stub",
                        subtitle: "Convert this request into a mock",
                        icon: "hammer.fill",
                        color: .accentColor
                    ) {
                        viewModel.createStub()
                    }
                }

                Divider()

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
        }
    }

    // MARK: - Export Button

    private func exportButton(title: String, subtitle: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
                    .frame(width: 36, height: 36)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(.quaternary)
            }
            .padding(12)
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

@available(iOS 16.0, *)
struct ExportTabView_Previews: PreviewProvider {
    static var previews: some View {
        ExportTabView(viewModel: .mock())
    }
}
