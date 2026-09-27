//
//  SecurityIssuesView.swift
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

// MARK: - Security Issues View

struct SecurityIssuesView: View {
    @StateObject private var issueManager = SecurityIssueManager.shared
    let requestRepository: RequestRepositoryProtocol

    var body: some View {
        List {
            summarySection

            ForEach(issueManager.issues.sorted { severityRank($0.severity) < severityRank($1.severity) }) { issue in
                issueRow(issue)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Security Issues")
    }

    private var summarySection: some View {
        Section {
            HStack(spacing: 12) {
                summaryBadge(count: issueManager.issueCounts.critical, color: .red, label: "Critical")
                summaryBadge(count: issueManager.issueCounts.high, color: .orange, label: "High")
                summaryBadge(count: issueManager.issueCounts.medium, color: .yellow, label: "Medium")
                summaryBadge(count: issueManager.issueCounts.low, color: .blue, label: "Low")
            }
        } header: {
            Text("Summary")
        }
    }

    private func summaryBadge(count: Int, color: Color, label: String) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(count > 0 ? color : .secondary)

            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }

    private func issueRow(_ issue: SecurityIssue) -> some View {
        InspectlyNavigationLink(destination: {
            requestDetail(for: issue.requestID)
        }, label: {
            HStack(spacing: 12) {
                Image(systemName: issue.severity.iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(issue.severity.color)
                    .cornerRadius(8)

                VStack(alignment: .leading, spacing: 3) {
                    Text(issue.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(issue.description)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    Text(issue.category.rawValue)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(issue.severity.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(issue.severity.color.opacity(0.1))
                        .cornerRadius(4)
                }

                Spacer()
            }
            .padding(.vertical, 4)
        })
    }

    private func requestDetail(for requestID: UUID) -> some View {
        AsyncRequestDetailView(requestID: requestID, requestRepository: requestRepository)
    }

    private func severityRank(_ severity: SecuritySeverity) -> Int {
        switch severity {
        case .critical: return 0
        case .high: return 1
        case .medium: return 2
        case .low: return 3
        }
    }
}

// MARK: - Async Request Detail

private struct AsyncRequestDetailView: View {
    let requestID: UUID
    let requestRepository: RequestRepositoryProtocol
    @State private var request: NetworkRequest?

    var body: some View {
        Group {
            if let request = request {
                RequestDetailView(
                    viewModel: RequestDetailViewModel(
                        request: request,
                        requestRepository: requestRepository
                    )
                )
            } else {
                ProgressView("Loading request…")
            }
        }
        .task {
            request = await requestRepository.getRequest(by: requestID)
        }
    }
}

// MARK: - Preview

struct SecurityIssuesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SecurityIssuesView(requestRepository: MockRequestRepository())
        }
        .navigationViewStyle(.stack)
    }
}


