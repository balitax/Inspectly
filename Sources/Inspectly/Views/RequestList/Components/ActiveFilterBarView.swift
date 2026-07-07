//
//  ActiveFilterBarView.swift
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

// MARK: - Active Filter Bar

@available(iOS 16.0, *)
struct ActiveFilterBarView: View {
    @ObservedObject var viewModel: RequestListViewModel

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "line.3.horizontal.decrease")
                .font(.system(size: 11))
                .foregroundStyle(.accentColor)

            Text("\(viewModel.totalFilteredCount) results")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.primary)

            Text("filtered")
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)

            Spacer()

            Button {
                viewModel.clearFilter()
                viewModel.searchText = ""
            } label: {
                Text("Clear")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}
