//
//  AboutSectionView.swift
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

// MARK: - About Section

@available(iOS 16.0, *)
struct AboutSectionView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Section {
            HStack(spacing: 14) {
                Image(systemName: "network")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.accentIndigo)
                    .frame(width: 44, height: 44)
                    .background(Color.accentIndigo.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Inspectly")
                        .font(.system(size: 15, weight: .bold))
                    Text("Network debugger for iOS developers")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)

            HStack(spacing: 12) {
                SettingsRow.icon("tag.fill", color: Color(.systemGray))
                Text("Version")
                    .font(.system(size: 15))
                Spacer()
                Text("\(viewModel.appVersion) (\(viewModel.buildNumber))")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                SettingsRow.icon("person.fill", color: .pink)
                Text("Developer")
                    .font(.system(size: 15))
                Spacer()
                Text("Agus Cahyono")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
        } header: {
            SettingsRow.sectionHeader("About")
        }
    }
}
