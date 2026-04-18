//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import SwiftUI

// MARK: - Card Style Modifier

struct CardStyleModifier: ViewModifier {
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Code Block Style Modifier

struct CodeBlockStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.caption, design: .monospaced))
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

// MARK: - Section Card Style

struct SectionCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Color.cardBackgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Badge Style

struct BadgeStyleModifier: ViewModifier {
    var color: Color
    var isSmall: Bool

    func body(content: Content) -> some View {
        content
            .font(isSmall ? .system(size: 10, weight: .bold, design: .monospaced) : .system(size: 12, weight: .semibold, design: .monospaced))
            .padding(.horizontal, isSmall ? 6 : 8)
            .padding(.vertical, isSmall ? 2 : 4)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle(padding: CGFloat = 16, cornerRadius: CGFloat = 16) -> some View {
        modifier(CardStyleModifier(padding: padding, cornerRadius: cornerRadius))
    }

    func codeBlockStyle() -> some View {
        modifier(CodeBlockStyleModifier())
    }

    func sectionCardStyle() -> some View {
        modifier(SectionCardModifier())
    }

    func badgeStyle(color: Color, isSmall: Bool = false) -> some View {
        modifier(BadgeStyleModifier(color: color, isSmall: isSmall))
    }
}

// MARK: - Activity View (Share Sheet)

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

