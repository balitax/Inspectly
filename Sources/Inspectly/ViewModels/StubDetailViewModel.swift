//
//  StubDetailViewModel.swift
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
    @Published var validationErrors: [String] = []

    private let stubRepository: StubRepositoryProtocol

    var response: StubResponse {
        get {
            if stub.scenarios.isEmpty {
                stub.scenarios.append(StubScenario(name: "Default"))
            }
            return stub.scenarios[0].response
        }
        set {
            if stub.scenarios.isEmpty {
                stub.scenarios.append(StubScenario(name: "Default"))
            }
            stub.scenarios[0].response = newValue
        }
    }

    init(stub: RequestStub, isEditing: Bool = false, stubRepository: StubRepositoryProtocol) {
        self.stub = stub
        self.isEditing = isEditing
        self.stubRepository = stubRepository
    }

    // MARK: - Method Editing

    func updateMethod(_ method: HTTPMethodType) {
        stub.method = method
    }

    // MARK: - JSON Validation

    func validateJSON() {
        guard let json = response.jsonBody, !json.isEmpty else {
            jsonValidationError = nil
            return
        }

        if json.isValidJSON {
            jsonValidationError = nil
        } else {
            jsonValidationError = "Invalid JSON syntax. Please check your response body."
        }
    }

    // MARK: - Validation

    @discardableResult
    func validate() -> Bool {
        var errors: [String] = []

        if stub.name.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append("Stub name is required.")
        }

        validationErrors = errors
        return errors.isEmpty
    }

    var isValid: Bool { validationErrors.isEmpty }

    // MARK: - Save

    func save() async {
        stub.updatedAt = Date()

        let existing = await stubRepository.getStub(by: stub.id)
        if existing != nil {
            await stubRepository.updateStub(stub)
        } else {
            await stubRepository.addStub(stub)
        }
    }

    // MARK: - Mock

    static func mock() -> StubDetailViewModel {
        StubDetailViewModel(
            stub: RequestStub(
                name: "Mock Stub",
                method: .get
            ),
            isEditing: true,
            stubRepository: MockStubRepository()
        )
    }
}
