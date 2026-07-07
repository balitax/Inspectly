//
//  StorageSectionView.swift
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

// MARK: - Storage Section

@available(iOS 16.0, *)
struct StorageSectionView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Section {
            HStack(spacing: 12) {
                SettingsRow.icon("internaldrive.fill", color: .blue)
                Text("Max Stored Requests")
                    .font(.system(size: 15))
                Spacer()
                Picker("", selection: $viewModel.settings.maxStoredRequests) {
                    Text("100").tag(100)
                    Text("250").tag(250)
                    Text("500").tag(500)
                    Text("1000").tag(1000)
                    Text("2500").tag(2500)
                }
                .pickerStyle(.menu)
            }
        } header: {
            SettingsRow.sectionHeader("Storage")
        } footer: {
            Text("Older requests are automatically removed when this limit is reached.")
        }
    }
}
