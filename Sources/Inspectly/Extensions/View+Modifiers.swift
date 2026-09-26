//
//  View+Modifiers.swift
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

// MARK: - Card Style Modifier

struct CardStyleModifier: ViewModifier {
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.cardBackground)
            .cornerRadius(cornerRadius)
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
            .cornerRadius(10)
    }
}

// MARK: - Section Card Style

struct SectionCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Color.cardBackgroundSecondary)
            .cornerRadius(14)
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
            .foregroundColor(color)
            .cornerRadius(6)
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

    /// iOS 15 replacement for `.foregroundStyle(_:)`
    func foregroundStyle(_ color: Color) -> some View {
        self.foregroundColor(color)
    }

    /// iOS 15 replacement for `.foregroundStyle(_:)` with semantic styles.
    /// Because `Color` is a concrete `ShapeStyle` on iOS 15, we only support `Color` here.
    func foregroundStyle<S>(_ style: S) -> some View where S: ShapeStyle {
        self.foregroundColor(style as? Color)
    }

    /// iOS 15 replacement for `.overlay(alignment:content:)`
    func overlay<Content: View>(alignment: Alignment, @ViewBuilder content: () -> Content) -> some View {
        self.overlay(content(), alignment: alignment)
    }

    /// iOS 15 replacement for `.background { ... }`
    func background<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        self.background(content())
    }

    /// iOS 15 replacement for `.safeAreaInset(edge:alignment:spacing:content:)`
    func safeAreaInset<Content: View>(edge: VerticalEdge, spacing: CGFloat = 0, @ViewBuilder content: () -> Content) -> some View {
        self.overlay(
            VStack {
                if edge == .top {
                    content()
                }
                Spacer()
                if edge == .bottom {
                    content()
                }
            }
            .padding(.bottom, edge == .bottom ? spacing : 0)
            .padding(.top, edge == .top ? spacing : 0)
            .allowsHitTesting(false)
        )
    }

    /// iOS 15 replacement for `.controlSize(_:)`
    func controlSizeCompat(_ size: ControlSizeCompat) -> some View {
        self.modifier(ControlSizeModifier(size: size))
    }

    /// iOS 15 replacement for `.fontWeight(_:)`
    func fontWeight(_ weight: Font.Weight) -> some View {
        self.modifier(FontWeightModifier(weight: weight))
    }
}

// MARK: - Control Size Compatibility

enum ControlSizeCompat {
    case mini
    case small
}

struct ControlSizeModifier: ViewModifier {
    let size: ControlSizeCompat

    func body(content: Content) -> some View {
        switch size {
        case .mini:
            content.frame(height: 24)
        case .small:
            content.frame(height: 28)
        }
    }
}

// MARK: - Font Weight Modifier

struct FontWeightModifier: ViewModifier {
    let weight: Font.Weight

    func body(content: Content) -> some View {
        content.font(.body.weight(weight))
    }
}

// MARK: - Vertical Edge

enum VerticalEdge {
    case top
    case bottom
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
