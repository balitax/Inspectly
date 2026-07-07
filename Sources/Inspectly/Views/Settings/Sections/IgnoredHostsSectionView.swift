//
//  IgnoredHostsSectionView.swift
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

// MARK: - Ignored Hosts Section

@available(iOS 16.0, *)
struct IgnoredHostsSectionView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Section {
            ForEach(viewModel.settings.ignoredHosts) { host in
                Toggle(isOn: Binding(
                    get: { host.isEnabled },
                    set: { _ in viewModel.toggleIgnoredHost(host) }
                )) {
                    Text(host.host)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(host.isEnabled ? .primary : .secondary)
                }
                .tint(.orange)
                .swipeActions {
                    Button(role: .destructive) {
                        viewModel.removeIgnoredHost(host)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }

            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(viewModel.newIgnoredHost.isEmpty ? Color(.tertiaryLabel) : .green)

                TextField("Add host to ignore...", text: $viewModel.newIgnoredHost)
                    .font(.system(size: 13, design: .monospaced))
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .onSubmit { viewModel.addIgnoredHost() }

                if !viewModel.newIgnoredHost.isEmpty {
                    Button {
                        viewModel.addIgnoredHost()
                    } label: {
                        Text("Add")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.green)
                    }
                }
            }
        } header: {
            SettingsRow.sectionHeader("Ignored Hosts")
        } footer: {
            Text("Requests to these hosts will not be captured.")
        }
    }
}
