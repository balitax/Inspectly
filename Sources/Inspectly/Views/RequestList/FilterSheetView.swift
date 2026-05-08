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

struct FilterSheetView: View {
    @Binding var filter: RequestFilter
    let onApply: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        InspectlyNavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // MARK: - HTTP Method
                    filterCard(title: "HTTP Method", subtitle: "Filter by request method") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
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

                    // MARK: - Status Code
                    filterCard(title: "Status Code", subtitle: "Filter by response range") {
                        HStack(spacing: 8) {
                            statusRangeChip("2xx · Success", range: 200...299, color: .green)
                            statusRangeChip("3xx · Redirect", range: 300...399, color: .blue)
                            statusRangeChip("4xx · Client", range: 400...499, color: .orange)
                            statusRangeChip("5xx · Server", range: 500...599, color: .red)
                        }
                    }

                    // MARK: - Request Type
                    filterCard(title: "Request Type", subtitle: "Filter by properties") {
                        VStack(spacing: 0) {
                            filterToggleRow("Success Only", icon: "checkmark.circle.fill", color: .green, isOn: $filter.successOnly)
                            Divider().padding(.leading, 44)
                            filterToggleRow("Errors Only", icon: "xmark.octagon.fill", color: .red, isOn: $filter.errorOnly)
                            Divider().padding(.leading, 44)
                            filterToggleRow("Stubbed Only", icon: "hammer.fill", color: .accentColor, isOn: $filter.stubbedOnly)
                            Divider().padding(.leading, 44)
                            filterToggleRow("Favorites Only", icon: "heart.fill", color: .pink, isOn: $filter.favoritesOnly)
                            Divider().padding(.leading, 44)
                            filterToggleRow("Pinned Only", icon: "pin.fill", color: .orange, isOn: $filter.pinnedOnly)
                        }
                    }
                }
                .padding(16)
            }
            .background(Color.surfacePrimary)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        filter.reset()
                        onApply()
                    }
                    .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        onApply()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Filter Card

    private func filterCard<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .tracking(0.4)

                Text("·")
                    .foregroundStyle(.quaternary)

                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 10)

            Divider().padding(.horizontal, 14)

            content()
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
        }
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Status Range Chip

    private func statusRangeChip(_ label: String, range: ClosedRange<Int>, color: Color) -> some View {
        let isSelected = filter.statusCodeRange == range
        return Button {
            filter.statusCodeRange = isSelected ? nil : range
        } label: {
            Text(label)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(isSelected ? color : .secondary)
                .lineLimit(1)
                .padding(.horizontal, 8)
                .padding(.vertical, 7)
                .frame(maxWidth: .infinity)
                .background(isSelected ? color.opacity(0.12) : Color(.quaternarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(isSelected ? color.opacity(0.4) : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Filter Toggle Row

    private func filterToggleRow(_ label: String, icon: String, color: Color, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundStyle(color)
                    .frame(width: 22)

                Text(label)
                    .font(.system(size: 14))
                    .foregroundStyle(.primary)
            }
        }
        .toggleStyle(.switch)
        .tint(color)
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

struct FilterSheetView_Previews: PreviewProvider {
    static var previews: some View {
        FilterSheetView(filter: .constant(RequestFilter())) {}
    }
}
