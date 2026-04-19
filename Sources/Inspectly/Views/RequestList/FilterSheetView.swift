//
//  FilterSheetView.swift
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

// MARK: - Filter Sheet View

@available(iOS 16.0, *)
struct FilterSheetView: View {
    @Binding var filter: RequestFilter
    let onApply: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: - HTTP Method Filter
                    methodFilterSection

                    Divider()

                    // MARK: - Status Code Filter
                    statusCodeSection

                    Divider()

                    // MARK: - Boolean Filters
                    booleanFiltersSection
                }
                .padding(20)
            }
            .background(Color.surfacePrimary)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        filter.reset()
                        onApply()
                    }
                    .foregroundStyle(.secondary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply") {
                        onApply()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Method Filter

    private var methodFilterSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("HTTP Method")
                .font(.system(size: 14, weight: .semibold))

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(HTTPMethodType.allCases.filter { $0 != .head && $0 != .options }) { method in
                    FilterChipView(
                        label: method.rawValue,
                        isSelected: filter.methods.contains(method)
                    ) {
                        if filter.methods.contains(method) {
                            filter.methods.remove(method)
                        } else {
                            filter.methods.insert(method)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Status Code

    private var statusCodeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Status Code Range")
                .font(.system(size: 14, weight: .semibold))

            HStack(spacing: 8) {
                statusRangeChip("2xx", range: 200...299)
                statusRangeChip("3xx", range: 300...399)
                statusRangeChip("4xx", range: 400...499)
                statusRangeChip("5xx", range: 500...599)
            }
        }
    }

    private func statusRangeChip(_ label: String, range: ClosedRange<Int>) -> some View {
        FilterChipView(
            label: label,
            isSelected: filter.statusCodeRange == range
        ) {
            if filter.statusCodeRange == range {
                filter.statusCodeRange = nil
            } else {
                filter.statusCodeRange = range
            }
        }
    }

    // MARK: - Boolean Filters

    private var booleanFiltersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Request Type")
                .font(.system(size: 14, weight: .semibold))

            VStack(spacing: 0) {
                filterToggle("Success Only", icon: "checkmark.circle", isOn: $filter.successOnly)
                Divider().padding(.leading, 40)
                filterToggle("Errors Only", icon: "xmark.octagon", isOn: $filter.errorOnly)
                Divider().padding(.leading, 40)
                filterToggle("Stubbed Only", icon: "hammer", isOn: $filter.stubbedOnly)
                Divider().padding(.leading, 40)
                filterToggle("Favorites Only", icon: "heart", isOn: $filter.favoritesOnly)
                Divider().padding(.leading, 40)
                filterToggle("Pinned Only", icon: "pin", isOn: $filter.pinnedOnly)
            }
            .sectionCardStyle()
        }
    }

    private func filterToggle(_ label: String, icon: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Label(label, systemImage: icon)
                .font(.system(size: 14))
        }
        .toggleStyle(.switch)
        .tint(.accentColor)
        .padding(.vertical, 6)
    }
}

// MARK: - Preview

@available(iOS 16.0, *)
struct FilterSheetView_Previews: PreviewProvider {
    static var previews: some View {
        FilterSheetView(filter: .constant(RequestFilter())) {}
    }
}
