//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import SwiftUI

// MARK: - Status Badge View

struct StatusBadgeView: View {
    let statusCode: Int?

    var body: some View {
        Text(statusCode.map { "\($0)" } ?? "—")
            .font(.system(size: 12, weight: .bold, design: .monospaced))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor.opacity(0.15))
            .foregroundStyle(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    private var backgroundColor: Color {
        Color.forStatusCode(statusCode)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 12) {
        StatusBadgeView(statusCode: 200)
        StatusBadgeView(statusCode: 301)
        StatusBadgeView(statusCode: 404)
        StatusBadgeView(statusCode: 500)
        StatusBadgeView(statusCode: nil)
    }
    .padding()
}
