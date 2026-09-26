//
//  RequestListBanners.swift
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

// MARK: - Error Banner

struct ErrorBannerView: View {
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.red)
                .frame(width: 32, height: 32)
                .background(Color.red.opacity(0.12))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 2) {
                Text("Storage Error")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.red)

                Text(message)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(.vertical, 6)
        .listRowBackground(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.red.opacity(0.07))
                .padding(.horizontal, 4)
                .padding(.vertical, 3)
        )
    }
}

// MARK: - Throttling Banner

struct ThrottlingBannerView: View {
    let throttling: NetworkThrottlingPreset

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: throttling.iconName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.orange)
                .frame(width: 32, height: 32)
                .background(Color.orange.opacity(0.12))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 2) {
                Text("Throttling: \(throttling.displayName)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.orange)

                Text(throttling.description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.vertical, 6)
        .listRowBackground(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.orange.opacity(0.07))
                .padding(.horizontal, 4)
                .padding(.vertical, 3)
        )
    }
}
