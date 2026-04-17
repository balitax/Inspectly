//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation

// MARK: - Stub Repository Protocol

protocol StubRepositoryProtocol {
    func getAllStubs() async -> [RequestStub]
    func getStub(by id: UUID) async -> RequestStub?
    func addStub(_ stub: RequestStub) async
    func updateStub(_ stub: RequestStub) async
    func deleteStub(_ id: UUID) async
    func deleteAllStubs() async
    func findMatchingStub(for request: NetworkRequest) async -> RequestStub?
    func toggleStub(_ id: UUID, enabled: Bool) async
    func duplicateStub(_ id: UUID) async -> RequestStub?
    func incrementUsageCount(_ id: UUID) async
}
