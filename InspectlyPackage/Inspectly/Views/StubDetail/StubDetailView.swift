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

                // MARK: - Scenarios
                scenarioSection

                // MARK: - Test
                testSection
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
        .alert("Test Result", isPresented: $viewModel.showTestResult) {
            Button("OK") {}
        } message: {
            Text(viewModel.testResultMessage)
        }
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

    // MARK: - Scenarios

    private var scenarioSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Scenarios", actionTitle: "Add") {
                viewModel.addScenario()
            }

            ScenarioListView(viewModel: viewModel)
        }
        .sectionCardStyle()
    }

    // MARK: - Test

    private var testSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Test")

            Button {
                viewModel.testStub()
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Test Match Rule")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
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
