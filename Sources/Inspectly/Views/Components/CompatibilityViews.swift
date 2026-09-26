//
//  CompatibilityViews.swift
//  Inspectly
//

import SwiftUI

// MARK: - Navigation Stack (iOS 15 compatible)

public struct InspectlyNavigationStack<Content: View>: View {
    let content: () -> Content

    public init(content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        NavigationView {
            content()
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Navigation Link (iOS 15 compatible)

public struct InspectlyNavigationLink<Destination: View, Content: View>: View {
    let destination: Destination
    let content: () -> Content

    public init(
        @ViewBuilder destination: @escaping () -> Destination,
        @ViewBuilder label: @escaping () -> Content
    ) {
        self.destination = destination()
        self.content = label
    }

    public var body: some View {
        NavigationLink(destination: destination) {
            content()
        }
    }
}
