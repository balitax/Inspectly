//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import SwiftUI

// MARK: - Code Block View

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

#Preview {
    VStack(spacing: 16) {
        CodeBlockView(
            title: "cURL",
            content: "curl -X GET \\\n  -H 'Authorization: Bearer token' \\\n  'https://api.example.com/users'"
        )

        CodeBlockView(
            title: "JSON Response",
            content: """
            {
              "id": 1,
              "name": "John Doe",
              "email": "john@example.com"
            }
            """
        )
    }
    .padding()
}
