//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import SwiftUI

// MARK: - JSON Preview View

struct JSONPreviewView: View {
    let json: String
    @State private var isValid: Bool = true
    @State private var prettyJSON: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("JSON Preview")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: isValid ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 11))
                    Text(isValid ? "Valid JSON" : "Invalid JSON")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundStyle(isValid ? .green : .red)
            }

            if isValid {
                ScrollView {
                    Text(prettyJSON)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(.primary)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 300)
                .padding(12)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)

                    Text("The JSON body contains syntax errors. Please fix them before saving.")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(Color.orange.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .onAppear {
            validate()
        }
        .onChange(of: json) { _ in
            validate()
        }
    }

    private func validate() {
        isValid = json.isEmpty || json.isValidJSON
        prettyJSON = json.prettyPrintedJSON ?? json
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        JSONPreviewView(json: """
        {"id": 1, "name": "John Doe", "email": "john@example.com"}
        """)

        JSONPreviewView(json: """
        {"invalid": json missing quote}
        """)
    }
    .padding()
}
