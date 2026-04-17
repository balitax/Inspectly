//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
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
                    .foregroundStyle(color)
                    .frame(width: 32, height: 32)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                Spacer()

                if let trend = trend {
                    Text(trend)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(trend.hasPrefix("+") ? .green : .red)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text(title)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
        SummaryCardView(title: "Total Requests", value: "1,234", icon: "arrow.up.arrow.down", color: .primaryGreen, trend: "+12%")
        SummaryCardView(title: "Failed", value: "23", icon: "xmark.circle.fill", color: .red, trend: "-5%")
        SummaryCardView(title: "Avg Response", value: "234ms", icon: "clock.fill", color: .teal)
        SummaryCardView(title: "Success Rate", value: "98.1%", icon: "checkmark.seal.fill", color: .green)
    }
    .padding()
}
