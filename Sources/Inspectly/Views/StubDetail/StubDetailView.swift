//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import SwiftUI

// MARK: - Stub Detail View

struct StubDetailView: View {
    @StateObject var viewModel: StubDetailViewModel
    var onSave: ((RequestStub) -> Void)?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
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
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    Task {
                        await viewModel.save()
                        onSave?(viewModel.stub)
                        dismiss()
                    }
                }
                .fontWeight(.semibold)
            }
        }
        .toolbar(.hidden, for: .tabBar)
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

            ResponseEditorView(
                response: Binding(
                    get: { viewModel.response },
                    set: { viewModel.response = $0 }
                ),
                onValidateJSON: {
                    viewModel.validateJSON()
                },
                jsonError: viewModel.jsonValidationError
            )
        }
        .sectionCardStyle()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        StubDetailView(viewModel: .mock())
    }
}
