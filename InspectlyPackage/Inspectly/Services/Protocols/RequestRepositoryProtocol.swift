//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation

// MARK: - Request Repository Protocol

public protocol RequestRepositoryProtocol {
    func getAllRequests() async -> [NetworkRequest]
    func getRequest(by id: UUID) async -> NetworkRequest?
    func addRequest(_ request: NetworkRequest) async
    func updateRequest(_ request: NetworkRequest) async
    func deleteRequest(_ id: UUID) async
    func deleteAllRequests() async
    func searchRequests(query: String) async -> [NetworkRequest]
    func getRequestCount() async -> Int
}
