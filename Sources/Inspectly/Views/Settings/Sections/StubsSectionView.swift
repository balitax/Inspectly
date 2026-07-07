//
//  StubsSectionView.swift
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

// MARK: - Stubs Section

@available(iOS 16.0, *)
struct StubsSectionView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Section {
            Toggle(isOn: $viewModel.settings.areStubsEnabled) {
                SettingsRow.labeled(icon: "hammer.fill", color: .accentIndigo, title: "Enable Stubs Globally")
            }
            .tint(.accentIndigo)
        } header: {
            SettingsRow.sectionHeader("Stubs")
        } footer: {
            Text("When enabled, matching network requests will return stubbed responses.")
        }
    }
}
