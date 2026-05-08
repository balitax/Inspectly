//
//  StubDetailView.swift
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

// MARK: - Stub Detail View

@available(iOS 16.0, *)
struct StubDetailView: View {
    @StateObject var viewModel: StubDetailViewModel
    var onSave: ((RequestStub) async -> Void)?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Validation Errors
                if !viewModel.validationErrors.isEmpty {
                    validationErrorBanner
                }

                // MARK: - General Info
                generalInfoSection

                // MARK: - Match Rules
                matchRuleSection

                // MARK: - Response Data
                responseDataSection
            }
            .padding(16)
        }
        .background(Color.surfacePrimary)
        .navigationTitle(viewModel.stub.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    guard viewModel.validate() else { return }
                    Task {
                        await viewModel.save()
                        await onSave?(viewModel.stub)
                        dismiss()
                    }
                }
                .fontWeight(.semibold)
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }

    // MARK: - Validation Error Banner

    private var validationErrorBanner: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.red)
                Text("Fix the following before saving:")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.red)
            }

            ForEach(viewModel.validationErrors, id: \.self) { error in
                HStack(spacing: 6) {
                    Circle()
                        .fill(.red.opacity(0.6))
                        .frame(width: 4, height: 4)
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundStyle(.red.opacity(0.85))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.red.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Color.red.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - General Info

    private var generalInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "General")

            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Name")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    TextField("Stub name", text: $viewModel.stub.name)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 14))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Description")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    TextField("Description", text: $viewModel.stub.description)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 14))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Group")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    TextField("Group name", text: Binding(
                        get: { viewModel.stub.groupName ?? "" },
                        set: { viewModel.stub.groupName = $0.isEmpty ? nil : $0 }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 14))
                }

                Toggle("Enabled", isOn: $viewModel.stub.isEnabled)
                    .tint(.green)
            }
        }
        .sectionCardStyle()
    }

    // MARK: - Match Rule

    private var matchRuleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Match Rules")

            MatchRuleEditorView(viewModel: viewModel)
        }
        .sectionCardStyle()
    }

    // MARK: - Response Data

    private var responseDataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Response Data")

            ResponseEditorView(viewModel: viewModel)
        }
        .sectionCardStyle()
    }
}

// MARK: - Preview

@available(iOS 16.0, *)
struct StubDetailView_Previews: PreviewProvider {
    static var previews: some View {
        InspectlyNavigationStack {
            StubDetailView(viewModel: .mock())
        }
    }
}
