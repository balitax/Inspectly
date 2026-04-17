//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import SwiftUI

// MARK: - Scenario List View

struct ScenarioListView: View {
    @ObservedObject var viewModel: StubDetailViewModel

    var body: some View {
        VStack(spacing: 10) {
            if viewModel.stub.scenarios.isEmpty {
                Text("No scenarios. Add one to configure a mock response.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            } else {
                ForEach(viewModel.stub.scenarios) { scenario in
                    scenarioCard(scenario)
                }
            }
        }
    }

    // MARK: - Scenario Card

    private func scenarioCard(_ scenario: StubScenario) -> some View {
        DisclosureGroup {
            ResponseEditorView(
                response: Binding(
                    get: { viewModel.getScenario(scenario.id)?.response ?? StubResponse() },
                    set: { newResponse in
                        var updated = scenario
                        updated.response = newResponse
                        viewModel.updateScenario(updated)
                    }
                ),
                onValidateJSON: {
                    viewModel.validateJSON(for: scenario.id)
                },
                jsonError: viewModel.jsonValidationError
            )
            .padding(.top, 8)

            // MARK: - Error Presets
            VStack(alignment: .leading, spacing: 8) {
                Text("Quick Presets")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        presetButton("Timeout", errorType: .timeout, scenarioId: scenario.id)
                        presetButton("401", errorType: .unauthorized, scenarioId: scenario.id)
                        presetButton("403", errorType: .forbidden, scenarioId: scenario.id)
                        presetButton("404", errorType: .notFound, scenarioId: scenario.id)
                        presetButton("500", errorType: .internalServerError, scenarioId: scenario.id)
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                Button {
                    viewModel.setActiveScenario(scenario.id)
                } label: {
                    Image(systemName: scenario.isActive ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(scenario.isActive ? .green : .secondary)
                        .font(.system(size: 18))
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 2) {
                    Text(scenario.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.primary)

                    HStack(spacing: 6) {
                        StatusBadgeView(statusCode: scenario.response.statusCode)
                        if scenario.response.responseDelay > 0 {
                            Text(String(format: "+%.1fs", scenario.response.responseDelay))
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(.tertiary)
                        }
                        if scenario.response.errorType != .none {
                            Image(systemName: scenario.response.errorType.iconName)
                                .font(.system(size: 10))
                                .foregroundStyle(.orange)
                        }
                    }
                }

                Spacer()

                Button {
                    viewModel.deleteScenario(scenario.id)
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundStyle(.red.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    // MARK: - Preset Button

    private func presetButton(_ label: String, errorType: StubErrorType, scenarioId: UUID) -> some View {
        Button {
            viewModel.applyErrorPreset(errorType, to: scenarioId)
        } label: {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.orange.opacity(0.12))
                .foregroundStyle(.orange)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        ScenarioListView(viewModel: .mock())
            .padding()
    }
}
