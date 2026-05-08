//
//  CompatibilityViews.swift
//  Inspectly
//
//  Created by Gemini CLI on 22/04/2026.
//

import SwiftUI

public struct InspectlyNavigationStack<Content: View>: View {
    let content: () -> Content
    
    public init(content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack(root: content)
        } else {
            NavigationView {
                content()
            }
            .navigationViewStyle(.stack)
        }
    }
}

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
        if #available(iOS 16.0, *) {
            NavigationLink(value: value, label: content)
        } else {
            NavigationLink(destination: destination(value), label: content)
        }
    }
}

extension View {
    @ViewBuilder
    func inspectlyNavigationDestination<D: View, V: Hashable>(for data: V.Type, @ViewBuilder destination: @escaping (V) -> D) -> some View {
        if #available(iOS 16.0, *) {
            self.navigationDestination(for: data, destination: destination)
        } else {
            self
        }
    }

    @ViewBuilder
    func inspectlyPresentationDetents(_ detents: Set<InspectlyDetent>) -> some View {
        if #available(iOS 16.0, *) {
            let swiftUIDetents = detents.map { d -> PresentationDetent in
                switch d {
                case .medium: return .medium
                case .large: return .large
                }
            }
            self.presentationDetents(Set(swiftUIDetents))
        } else {
            // Fallback for iOS 15 is handled via UISheetPresentationController in Inspectly.swift
            // for the main view. For nested sheets, we can try to find the VC.
            self.modifier(SheetDetentModifier(detents: detents))
        }
    }
}

enum InspectlyDetent: Hashable {
    case medium
    case large
}

struct SheetDetentModifier: ViewModifier {
    let detents: Set<InspectlyDetent>
    
    func body(content: Content) -> some View {
        content
            .background(SheetDetentConfigurator(detents: detents))
    }
}

struct SheetDetentConfigurator: UIViewControllerRepresentable {
    let detents: Set<InspectlyDetent>
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if #available(iOS 15.0, *) {
            if let sheet = uiViewController.parent?.presentationController as? UISheetPresentationController {
                let uiDetents: [UISheetPresentationController.Detent] = detents.map { d in
                    switch d {
                    case .medium: return .medium()
                    case .large: return .large()
                    }
                }
                sheet.detents = uiDetents
                sheet.prefersGrabberVisible = true
            }
        }
    }
}
