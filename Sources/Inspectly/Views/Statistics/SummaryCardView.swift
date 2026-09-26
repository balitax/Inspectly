//
//  SummaryCardView.swift
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

// MARK: - Summary Card View

struct SummaryCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var trend: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                    .background(color.opacity(0.12))
                    .cornerRadius(8)

                Spacer()

                if let trend = trend {
                    Text(trend)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(trend.hasPrefix("+") ? .green : .red)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(Color.surfaceElevated)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Preview

struct SummaryCardView_Previews: PreviewProvider {
    static var previews: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            SummaryCardView(title: "Total Requests", value: "1,234", icon: "arrow.up.arrow.down", color: .accentColor, trend: "+12%")
            SummaryCardView(title: "Failed", value: "23", icon: "xmark.circle.fill", color: .red, trend: "-5%")
            SummaryCardView(title: "Avg Response", value: "234ms", icon: "clock.fill", color: .teal)
            SummaryCardView(title: "Success Rate", value: "98.1%", icon: "checkmark.seal.fill", color: .green)
        }
        .padding()
    }
}
