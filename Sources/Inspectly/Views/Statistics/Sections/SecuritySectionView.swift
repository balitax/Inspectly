//
//  SecuritySectionView.swift
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

// MARK: - Security Section

struct SecuritySectionView: View {
    @StateObject private var issueManager = SecurityIssueManager.shared
    let requestRepository: RequestRepositoryProtocol

    var body: some View {
        StatsCardView(title: "Security Scanner", subtitle: "Auto-detected issues") {
            InspectlyNavigationLink(destination: {
                SecurityIssuesView(requestRepository: requestRepository)
            }, label: {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        SettingsRow.icon("shield.lefthalf.fill", color: issueManager.issues.isEmpty ? .green : .red)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(issueManager.issues.isEmpty ? "No Issues Found" : "\(issueManager.issues.count) issue(s) found")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.primary)

                            Text("HTTP, missing headers, exposed secrets")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(.tertiaryLabel))
                    }

                    if !issueManager.issues.isEmpty {
                        HStack(spacing: 8) {
                            severityChip(count: issueManager.issueCounts.critical, color: .red)
                            severityChip(count: issueManager.issueCounts.high, color: .orange)
                            severityChip(count: issueManager.issueCounts.medium, color: .yellow)
                            severityChip(count: issueManager.issueCounts.low, color: .blue)
                        }
                    }
                }
            })
        }
    }

    private func severityChip(count: Int, color: Color) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)

            Text("\(count)")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}

// MARK: - Preview

struct SecuritySectionView_Previews: PreviewProvider {
    static var previews: some View {
        SecuritySectionView(requestRepository: MockRequestRepository())
            .padding()
    }
}
