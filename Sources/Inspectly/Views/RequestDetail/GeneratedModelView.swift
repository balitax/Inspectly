//
//  GeneratedModelView.swift
//  Inspectly
//
//  Created by OpenCode on 27/09/2026.
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

// MARK: - Generated Model View

struct GeneratedModelView: View {
    let code: String
    @State private var showShareSheet: Bool = false
    @State private var copiedToClipboard: Bool = false

    var body: some View {
        InspectlyNavigationStack {
            VStack(spacing: 0) {
                codeEditor
                copyButton
            }
            .navigationTitle("Generated Model")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ActivityView(activityItems: [code])
            }
            .overlay(
                Group {
                    if copiedToClipboard {
                        copiedBanner
                    }
                },
                alignment: .bottom
            )
        }
    }

    private var copiedBanner: some View {
        Text("Copied to clipboard")
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.8))
            .cornerRadius(16)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .padding(.bottom, 20)
    }

    private var codeEditor: some View {
        TextEditor(text: .constant(code))
            .font(.system(size: 13, design: .monospaced))
            .padding(8)
            .background(Color(.secondarySystemBackground))
    }

    private var copyButton: some View {
        Button {
            UIPasteboard.general.string = code
            copiedToClipboard = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                copiedToClipboard = false
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "doc.on.clipboard")
                Text("Copy to Clipboard")
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.accentIndigo)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemBackground))
    }

}

// MARK: - Preview

struct GeneratedModelView_Previews: PreviewProvider {
    static var previews: some View {
        GeneratedModelView(code: "struct User: Codable {\n    let id: Int\n    let name: String\n}")
    }
}
