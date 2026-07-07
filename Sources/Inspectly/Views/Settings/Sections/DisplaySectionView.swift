//
//  DisplaySectionView.swift
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

// MARK: - Display Section

@available(iOS 16.0, *)
struct DisplaySectionView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Section {
            HStack(spacing: 12) {
                SettingsRow.icon("circle.lefthalf.filled", color: .purple)
                Text("Theme")
                    .font(.system(size: 15))
                Spacer()
                Picker("", selection: Binding(
                    get: {
                        switch viewModel.settings.isDarkModeOverride {
                        case .some(true): return 2
                        case .some(false): return 1
                        case nil: return 0
                        }
                    },
                    set: { value in
                        switch value {
                        case 0: viewModel.settings.isDarkModeOverride = nil
                        case 1: viewModel.settings.isDarkModeOverride = false
                        case 2: viewModel.settings.isDarkModeOverride = true
                        default: viewModel.settings.isDarkModeOverride = nil
                        }
                    }
                )) {
                    Text("System").tag(0)
                    Text("Light").tag(1)
                    Text("Dark").tag(2)
                }
                .pickerStyle(.menu)
                .onChange(of: viewModel.settings.isDarkModeOverride) { _ in
                    Task { await viewModel.saveSettings() }
                }
            }

            Toggle(isOn: $viewModel.settings.isAutoResponsePrettifying) {
                SettingsRow.labeled(icon: "text.alignleft", color: .accentTeal, title: "Auto-Prettify JSON")
            }
            .tint(.accentTeal)

            Toggle(isOn: $viewModel.settings.isRequestBodyTruncation) {
                SettingsRow.labeled(icon: "scissors", color: Color(.systemGray), title: "Truncate Large Bodies")
            }
            .tint(Color(.systemGray))
        } header: {
            SettingsRow.sectionHeader("Display")
        }
    }
}
