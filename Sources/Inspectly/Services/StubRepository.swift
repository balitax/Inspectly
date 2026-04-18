//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation

// MARK: - Stub Repository

actor StubRepository: StubRepositoryProtocol {
    private var stubs: [RequestStub]
    private let storageManager: StorageManagerProtocol
    private let storageKey = "inspectly_stubs"

    init(storageManager: StorageManagerProtocol, initialStubs: [RequestStub] = []) {
        self.storageManager = storageManager
        self.stubs = initialStubs
    }

    func getAllStubs() async -> [RequestStub] {
        return stubs
    }

    func getStub(by id: UUID) async -> RequestStub? {
        return stubs.first { $0.id == id }
    }

    func addStub(_ stub: RequestStub) async {
        stubs.append(stub)
        await persist()
    }

    func updateStub(_ stub: RequestStub) async {
        if let index = stubs.firstIndex(where: { $0.id == stub.id }) {
            stubs[index] = stub
            await persist()
        }
    }

    func deleteStub(_ id: UUID) async {
        stubs.removeAll { $0.id == id }
        await persist()
    }

    func deleteAllStubs() async {
        stubs.removeAll()
        await persist()
    }

    func findMatchingStub(for request: NetworkRequest) async -> RequestStub? {
        return stubs.first { stub in
            stub.isEnabled && stub.matchRule.matches(request)
        }
    }

    func toggleStub(_ id: UUID, enabled: Bool) async {
        if let index = stubs.firstIndex(where: { $0.id == id }) {
            stubs[index].isEnabled = enabled
            await persist()
        }
    }
    
    func toggleStubEnabled(_ id: UUID, enabled: Bool) async {
        await toggleStub(id, enabled: enabled)
    }

    func duplicateStub(_ id: UUID) async -> RequestStub? {
        guard let original = stubs.first(where: { $0.id == id }) else { return nil }
        let duplicate = RequestStub(
            name: "\(original.name) (Copy)",
            description: original.description,
            matchRule: original.matchRule,
            scenarios: original.scenarios.map { scenario in
                StubScenario(
                    name: scenario.name,
                    description: scenario.description,
                    response: scenario.response,
                    isActive: scenario.isActive
                )
            },
            isEnabled: false,
            groupName: original.groupName
        )
        stubs.append(duplicate)
        await persist()
        return duplicate
    }

    func incrementUsageCount(_ id: UUID) async {
        if let index = stubs.firstIndex(where: { $0.id == id }) {
            stubs[index].usageCount += 1
            stubs[index].lastTriggered = Date()
            await persist()
        }
    }

    // MARK: - Persistence

    func loadFromStorage() async {
        do {
            if let stored = try await storageManager.load([RequestStub].self, forKey: storageKey) {
                self.stubs = stored
            }
        } catch {
            print("[Inspectly] Failed to load stubs: \(error)")
        }
    }

    private func persist() async {
        do {
            try await storageManager.save(stubs, forKey: storageKey)
        } catch {
            print("[Inspectly] Failed to persist stubs: \(error)")
        }
    }
}

// MARK: - Mock Stub Repository

actor MockStubRepository: StubRepositoryProtocol {
    private var stubs: [RequestStub]

    init(stubs: [RequestStub] = []) {
        self.stubs = stubs
    }

    func getAllStubs() async -> [RequestStub] { stubs }
    func getStub(by id: UUID) async -> RequestStub? { stubs.first { $0.id == id } }
    func addStub(_ stub: RequestStub) async { stubs.append(stub) }
    func updateStub(_ stub: RequestStub) async {
        if let idx = stubs.firstIndex(where: { $0.id == stub.id }) { stubs[idx] = stub }
    }
    func deleteStub(_ id: UUID) async { stubs.removeAll { $0.id == id } }
    func deleteAllStubs() async { stubs.removeAll() }
    func findMatchingStub(for request: NetworkRequest) async -> RequestStub? {
        stubs.first { $0.isEnabled && $0.matchRule.matches(request) }
    }
    func toggleStub(_ id: UUID, enabled: Bool) async {
        if let idx = stubs.firstIndex(where: { $0.id == id }) { stubs[idx].isEnabled = enabled }
    }
    func toggleStubEnabled(_ id: UUID, enabled: Bool) async {
        await toggleStub(id, enabled: enabled)
    }
    func duplicateStub(_ id: UUID) async -> RequestStub? { nil }
    func incrementUsageCount(_ id: UUID) async {
        if let idx = stubs.firstIndex(where: { $0.id == id }) { stubs[idx].usageCount += 1 }
    }
}
