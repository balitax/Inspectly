//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import SwiftUI

// MARK: - Mini Chart View

struct MiniChartView: View {
    let data: [Double]
    var barColor: Color = .chartPrimary
    var showLabels: Bool = true

    var body: some View {
        GeometryReader { geometry in
            let maxValue = max(data.max() ?? 1, 1)
            let barWidth = max((geometry.size.width - CGFloat(data.count - 1) * 2) / CGFloat(data.count), 2)

            HStack(alignment: .bottom, spacing: 2) {
                ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [barColor.opacity(0.8), barColor.opacity(0.4)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(
                                width: barWidth,
                                height: max(
                                    geometry.size.height * CGFloat(value / maxValue) * 0.85,
                                    2
                                )
                            )

                        if showLabels && data.count <= 24 {
                            if index % 6 == 0 {
                                Text("\(index)")
                                    .font(.system(size: 7))
                                    .foregroundStyle(.quaternary)
                            } else {
                                Text("")
                                    .font(.system(size: 7))
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 24) {
        MiniChartView(
            data: [2, 5, 3, 8, 12, 7, 4, 6, 9, 15, 11, 8, 3, 5, 7, 10, 14, 9, 6, 4, 3, 2, 1, 0]
        )
        .frame(height: 80)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))

        MiniChartView(
            data: [4, 8, 6, 12, 9, 15, 7],
            barColor: .teal,
            showLabels: false
        )
        .frame(height: 50)
        .padding()
    }
    .padding()
}
