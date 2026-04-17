//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation
import SwiftUI

// MARK: - Stub Detail View Model

@MainActor
final class StubDetailViewModel: ObservableObject {
    @Published var stub: RequestStub
    @Published var isEditing: Bool
    @Published var jsonValidationError: String?
    @Published var showTestResult: Bool = false
    @Published var testResultMessage: String = ""
    @Published var selectedScenarioId: UUID?

    private let stubRepository: StubRepositoryProtocol

    init(stub: RequestStub, isEditing: Bool = false, stubRepository: StubRepositoryProtocol) {
        self.stub = stub
        self.isEditing = isEditing
        self.stubRepository = stubRepository
        self.selectedScenarioId = stub.activeScenario?.id
    }

    // MARK: - Match Rule Editing

    func updateMethod(_ method: HTTPMethodType?) {
        stub.matchRule.method = method
    }

    func updateURLPath(_ path: String) {
        stub.matchRule.urlPath = path
    }

    func updateFullURL(_ url: String) {
        stub.matchRule.fullURL = url
    }

    func updateBodyContains(_ body: String) {
        stub.matchRule.bodyContains = body
    }

    func addMatchHeader() {
        stub.matchRule.headers.append(RequestHeader(key: "", value: ""))
    }

    func removeMatchHeader(at index: Int) {
        guard index < stub.matchRule.headers.count else { return }
        stub.matchRule.headers.remove(at: index)
    }

    func addMatchQueryParam() {
        stub.matchRule.queryParameters.append(QueryParameter(key: "", value: ""))
    }

    func removeMatchQueryParam(at index: Int) {
        guard index < stub.matchRule.queryParameters.count else { return }
        stub.matchRule.queryParameters.remove(at: index)
    }

    // MARK: - Scenario Management

    func addScenario() {
        let scenario = StubScenario(
            name: "Scenario \(stub.scenarios.count + 1)",
            response: StubResponse(statusCode: 200, jsonBody: "{\n  \n}")
        )
        stub.scenarios.append(scenario)
    }

    func deleteScenario(_ id: UUID) {
        stub.scenarios.removeAll { $0.id == id }
    }

    func setActiveScenario(_ id: UUID) {
        for i in 0..<stub.scenarios.count {
            stub.scenarios[i].isActive = (stub.scenarios[i].id == id)
        }
        selectedScenarioId = id
    }

    func getScenario(_ id: UUID) -> StubScenario? {
        stub.scenarios.first { $0.id == id }
    }

    func updateScenario(_ scenario: StubScenario) {
        if let index = stub.scenarios.firstIndex(where: { $0.id == scenario.id }) {
            stub.scenarios[index] = scenario
        }
    }

    // MARK: - JSON Validation

    func validateJSON(for scenarioId: UUID) {
        guard let scenario = getScenario(scenarioId),
              let json = scenario.response.jsonBody,
              !json.isEmpty else {
            jsonValidationError = nil
            return
        }

        if json.isValidJSON {
            jsonValidationError = nil
        } else {
            jsonValidationError = "Invalid JSON syntax. Please check your response body."
        }
    }

    // MARK: - Error Simulation Presets

    func applyErrorPreset(_ errorType: StubErrorType, to scenarioId: UUID) {
        guard let index = stub.scenarios.firstIndex(where: { $0.id == scenarioId }) else { return }
        stub.scenarios[index].response.errorType = errorType
        if let statusCode = errorType.statusCode {
            stub.scenarios[index].response.statusCode = statusCode
        }

        // Set appropriate error response body
        switch errorType {
        case .unauthorized:
            stub.scenarios[index].response.jsonBody = """
            {"error": "unauthorized", "message": "Authentication required."}
            """
        case .forbidden:
            stub.scenarios[index].response.jsonBody = """
            {"error": "forbidden", "message": "You don't have permission."}
            """
        case .notFound:
            stub.scenarios[index].response.jsonBody = """
            {"error": "not_found", "message": "Resource not found."}
            """
        case .internalServerError:
            stub.scenarios[index].response.jsonBody = """
            {"error": "internal_server_error", "message": "Something went wrong."}
            """
        case .timeout:
            stub.scenarios[index].response.responseDelay = 30.0
        default:
            break
        }
    }

    // MARK: - Test Stub

    func testStub() {
        // Build a mock request that would match
        let testRequest = NetworkRequest(
            method: stub.matchRule.method ?? .get,
            url: stub.matchRule.fullURL ?? "https://example.com\(stub.matchRule.urlPath ?? "/")",
            host: "example.com",
            path: stub.matchRule.urlPath ?? "/"
        )

        if stub.matchRule.matches(testRequest) {
            testResultMessage = "✅ Match rule would match the test request."
            if let scenario = stub.activeScenario {
                testResultMessage += "\n\nActive scenario: \(scenario.name)"
                testResultMessage += "\nStatus code: \(scenario.response.statusCode)"
                if scenario.response.responseDelay > 0 {
                    testResultMessage += "\nDelay: \(scenario.response.responseDelay)s"
                }
            } else {
                testResultMessage += "\n\n⚠️ No active scenario selected."
            }
        } else {
            testResultMessage = "❌ Match rule would NOT match the test request."
        }
        showTestResult = true
    }

    // MARK: - Save

    func save() async {
        stub.updatedAt = Date()
        await stubRepository.updateStub(stub)
    }

    // MARK: - Mock

    static func mock() -> StubDetailViewModel {
        StubDetailViewModel(
            stub: MockStubs.loginStub,
            isEditing: true,
            stubRepository: MockStubRepository()
        )
    }
}
