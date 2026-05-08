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

struct StubRowView: View {
    let stub: RequestStub

    var body: some View {
        HStack(spacing: 10) {
            // Left accent line (green=active, gray=inactive)
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(stub.isEnabled ? Color.stubActive : Color.stubInactive.opacity(0.4))
                .frame(width: 3)
                .padding(.vertical, 2)

            // Stub info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(stub.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    if let scenario = stub.activeScenario {
                        Text(scenario.name)
                            .font(.system(size: 9, weight: .semibold))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.stubBadge.opacity(0.1))
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
                            .background(Color(.quaternarySystemFill))
                            .foregroundStyle(.secondary)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }

                    Text(stub.pathDisplay)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 6)

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
        .padding(.vertical, 6)
    }
}

// MARK: - Preview

struct StubRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            StubRowView(stub: RequestStub(name: "Login Mock", matchRule: StubMatchRule(fullURL: "https://api.example.com/login")))
            StubRowView(stub: RequestStub(name: "User List", matchRule: StubMatchRule(fullURL: "https://api.example.com/users")))
        }
        .listStyle(.insetGrouped)
    }
}
