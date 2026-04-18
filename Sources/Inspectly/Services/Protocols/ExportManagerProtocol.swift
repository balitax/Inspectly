//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation

// MARK: - Export Manager Protocol

public protocol ExportManagerProtocol {
    func exportRequests(_ requests: [NetworkRequest]) async throws -> Data
    func exportStubs(_ stubs: [RequestStub]) async throws -> Data
    func exportAsJSON(_ requests: [NetworkRequest]) async throws -> String
    func generateShareableURL(for request: NetworkRequest) -> URL?
}
