//
//  JSONPreviewView.swift
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

// MARK: - JSON Preview View

@available(iOS 16.0, *)
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

@available(iOS 16.0, *)
struct JSONPreviewView_Previews: PreviewProvider {
    static var previews: some View {
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
}
