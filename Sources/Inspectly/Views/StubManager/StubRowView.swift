//
//  StubRowView.swift
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

// MARK: - Stub Row View

@available(iOS 16.0, *)
struct StubRowView: View {
    let stub: RequestStub

    var body: some View {
        HStack(spacing: 10) {
            // Enabled indicator
            Circle()
                .fill(stub.isEnabled ? Color.stubActive : Color.stubInactive)
                .frame(width: 8, height: 8)

            // Stub info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(stub.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    if let scenario = stub.activeScenario {
                        Text(scenario.name)
                            .font(.system(size: 9, weight: .semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.stubBadge.opacity(0.12))
                            .foregroundStyle(Color.stubBadge)
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: 6) {
                    if let method = stub.matchRule.method {
                        HTTPMethodBadge(method: method)
                    } else {
                        Text("ANY")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.15))
                            .foregroundStyle(.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }

                    Text(stub.pathDisplay)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Right side info
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 9))
                    Text("\(stub.usageCount)")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                }
                .foregroundStyle(.tertiary)

                if let lastTriggered = stub.lastTriggered {
                    Text(lastTriggered.relativeTimeString)
                        .font(.system(size: 10))
                        .foregroundStyle(.quaternary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

@available(iOS 16.0, *)
struct StubRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            StubRowView(stub: RequestStub(name: "Login Mock", matchRule: StubMatchRule(fullURL: "https://api.example.com/login")))
            StubRowView(stub: RequestStub(name: "User List", matchRule: StubMatchRule(fullURL: "https://api.example.com/users")))
        }
        .listStyle(.insetGrouped)
    }
}
