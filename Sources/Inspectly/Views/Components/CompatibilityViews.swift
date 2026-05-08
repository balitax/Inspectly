//
//  CompatibilityViews.swift
//  Inspectly
//

import SwiftUI

// MARK: - Navigation Stack

public struct InspectlyNavigationStack<Content: View>: View {
    let content: () -> Content

    public init(content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        NavigationStack(root: content)
    }
}

// MARK: - Navigation Link

public struct InspectlyNavigationLink<Value: Hashable, Destination: View, Content: View>: View {
    let value: Value
    let destination: (Value) -> Destination
    let content: () -> Content

    public init(value: Value, @ViewBuilder destination: @escaping (Value) -> Destination, @ViewBuilder label: @escaping () -> Content) {
        self.value = value
        self.destination = destination
        self.content = label
    }

    public var body: some View {
        NavigationLink(value: value, label: content)
    }
}

// MARK: - View Extensions

extension View {
    func inspectlyNavigationDestination<D: View, V: Hashable>(for data: V.Type, @ViewBuilder destination: @escaping (V) -> D) -> some View {
        self.navigationDestination(for: data, destination: destination)
    }

    func inspectlyPresentationDetents(_ detents: Set<InspectlyDetent>) -> some View {
        let swiftUIDetents: Set<PresentationDetent> = Set(detents.map { d in
            switch d {
            case .medium: return .medium
            case .large:  return .large
            }
        })
        return self.presentationDetents(swiftUIDetents)
    }
}

// MARK: - Detent Type

enum InspectlyDetent: Hashable {
    case medium
    case large
}
