//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import SwiftUI

// MARK: - Request Row View

struct RequestRowView: View {
    let request: NetworkRequest

    var body: some View {
        HStack(spacing: 10) {
            // Method badge
            HTTPMethodBadge(method: request.method)

            // Request info
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    Text(request.shortURL)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    if request.isStubbed {
                        Image(systemName: "hammer.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.indigo)
                            .padding(3)
                            .background(Color.indigo.opacity(0.12))
                            .clipShape(Circle())
                    }
                }

                HStack(spacing: 8) {
                    Text(request.host)
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)

                    Text("·")
                        .foregroundStyle(.quaternary)

                    Text(request.timestamp.relativeTimeString)
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            // Right side indicators
            VStack(alignment: .trailing, spacing: 4) {
                StatusBadgeView(statusCode: request.statusCode)

                HStack(spacing: 6) {
                    if request.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.orange)
                    }

                    if request.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.pink)
                    }

                    Text(request.formattedDuration)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(durationColor)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var durationColor: Color {
        guard let duration = request.duration else { return .secondary }
        if duration > 3.0 { return .red }
        if duration > 1.0 { return .orange }
        return .secondary
    }
}

// MARK: - Preview

#Preview {
    List {
        RequestRowView(request: MockRequests.getUsersList)
        RequestRowView(request: MockRequests.postLogin)
        RequestRowView(request: MockRequests.unauthorized)
        RequestRowView(request: MockRequests.serverError)
        RequestRowView(request: MockRequests.stubbedLogin)
        RequestRowView(request: MockRequests.slowRequest)
    }
    .listStyle(.insetGrouped)
}
