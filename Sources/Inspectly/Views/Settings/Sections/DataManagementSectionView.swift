//
//  DataManagementSectionView.swift
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

// MARK: - Data Management Section

@available(iOS 16.0, *)
struct DataManagementSectionView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Section {
            Button {
                Task { await viewModel.exportLogs() }
            } label: {
                HStack(spacing: 12) {
                    SettingsRow.icon("arrow.up.doc.fill", color: .blue)
                    Text("Export Logs")
                        .font(.system(size: 15))
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(.tertiaryLabel))
                }
            }

            Button {
                Task { await viewModel.exportStubs() }
            } label: {
                HStack(spacing: 12) {
                    SettingsRow.icon("hammer.circle.fill", color: .accentIndigo)
                    Text("Export Stubs")
                        .font(.system(size: 15))
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(.tertiaryLabel))
                }
            }

            Button {
                viewModel.showClearConfirmation = true
            } label: {
                HStack(spacing: 12) {
                    SettingsRow.icon("trash.fill", color: .red)
                    Text("Clear All Logs")
                        .font(.system(size: 15))
                        .foregroundStyle(.red)
                    Spacer()
                }
            }
        } header: {
            SettingsRow.sectionHeader("Data Management")
        }
    }
}
