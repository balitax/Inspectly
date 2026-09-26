//
//  NotificationsSectionView.swift
//  Inspectly
//
//  Created by OpenCode on 26/09/2026.
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

// MARK: - Notifications Section

struct NotificationsSectionView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var newHost: String = ""

    var body: some View {
        Group {
            Toggle(isOn: $viewModel.settings.alertSlowRequests) {
                SettingsRow.labeled(icon: "tortoise.fill", color: .orange, title: "Slow Request Alert")
            }
            .tint(.orange)

            if viewModel.settings.alertSlowRequests {
                HStack(spacing: 12) {
                    Color.clear.frame(width: 28, height: 1)
                    Text("Trigger when duration exceeds \(String(format: "%.1fs", viewModel.settings.slowRequestThreshold))")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }

            Toggle(isOn: $viewModel.settings.alertErrorRequests) {
                SettingsRow.labeled(icon: "xmark.octagon.fill", color: .red, title: "Error Response Alert")
            }
            .tint(.red)

            ForEach(viewModel.settings.alertHosts, id: \.self) { host in
                HStack {
                    Text(host)
                        .font(.system(size: 13, design: .monospaced))
                    Spacer()
                }
                .swipeActions {
                    Button(role: .destructive) {
                        removeHost(host)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }

            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(newHost.isEmpty ? Color(.tertiaryLabel) : .green)

                TextField("Add host to alert...", text: $newHost)
                    .font(.system(size: 13, design: .monospaced))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onSubmit { addHost() }

                if !newHost.isEmpty {
                    Button {
                        addHost()
                    } label: {
                        Text("Add")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.green)
                    }
                }
            }
        }
    }

    private func addHost() {
        let trimmed = newHost.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !viewModel.settings.alertHosts.contains(trimmed) else { return }
        viewModel.settings.alertHosts.append(trimmed)
        newHost = ""
        Task { await viewModel.saveSettings() }
    }

    private func removeHost(_ host: String) {
        viewModel.settings.alertHosts.removeAll { $0 == host }
        Task { await viewModel.saveSettings() }
    }
}

// MARK: - Preview

struct NotificationsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            NotificationsSectionView(viewModel: .mock())
        }
        .listStyle(.insetGrouped)
    }
}
