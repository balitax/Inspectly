//
//  CodeBlockView.swift
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

// MARK: - Code Block View

@available(iOS 16.0, *)
struct CodeBlockView: View {
    let title: String?
    let content: String
    var showCopyButton: Bool = true
    var maxLines: Int? = nil

    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = title {
                HStack {
                    Text(title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)

                    Spacer()

                    if showCopyButton {
                        Button {
                            UIPasteboard.general.string = content
                            withAnimation(.spring(response: 0.3)) {
                                copied = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation { copied = false }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: copied ? "checkmark" : "doc.on.doc")
                                    .font(.system(size: 10))
                                Text(copied ? "Copied" : "Copy")
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .foregroundStyle(copied ? .green : .secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                Text(displayContent)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)
                    .lineLimit(maxLines)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var displayContent: String {
        if let maxLines = maxLines {
            let lines = content.components(separatedBy: "\n")
            if lines.count > maxLines {
                return lines.prefix(maxLines).joined(separator: "\n") + "\n..."
            }
        }
        return content
    }
}

// MARK: - Preview

@available(iOS 16.0, *)
struct CodeBlockView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CodeBlockView(
                title: "Response Headers",
                content: "Content-Type: application/json\nCache-Control: no-cache\nServer: nginx"
            )
            
            CodeBlockView(
                title: "JSON Body",
                content: "{\n  \"status\": \"success\",\n  \"data\": {\n    \"id\": 123,\n    \"name\": \"Inspectly\"\n  }\n}"
            )
        }
        .padding()
    }
}
