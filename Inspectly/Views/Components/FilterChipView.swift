//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import SwiftUI

// MARK: - Filter Chip View

struct FilterChipView: View {
    let label: String
    let isSelected: Bool
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 10))
                }
                Text(label)
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color(.tertiarySystemFill))
            .foregroundStyle(isSelected ? Color.accentColor : .secondary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? Color.accentColor.opacity(0.3) : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Filter Chip Group

struct FilterChipGroup<T: Identifiable & Hashable>: View {
    let items: [T]
    let selected: Set<T>
    let label: (T) -> String
    let toggle: (T) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items) { item in
                    FilterChipView(
                        label: label(item),
                        isSelected: selected.contains(item)
                    ) {
                        toggle(item)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        FilterChipView(label: "GET", isSelected: true, icon: "network") {}
        FilterChipView(label: "POST", isSelected: false) {}
        FilterChipView(label: "Errors", isSelected: true, icon: "exclamationmark.triangle") {}

        HStack(spacing: 8) {
            FilterChipView(label: "Success", isSelected: false) {}
            FilterChipView(label: "Failed", isSelected: true) {}
            FilterChipView(label: "Stubbed", isSelected: false, icon: "hammer") {}
        }
    }
    .padding()
}
