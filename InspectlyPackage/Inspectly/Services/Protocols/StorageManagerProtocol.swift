//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation

// MARK: - Storage Manager Protocol

public protocol StorageManagerProtocol {
    func save<T: Encodable>(_ data: T, forKey key: String) async throws
    func load<T: Decodable>(_ type: T.Type, forKey key: String) async throws -> T?
    func delete(forKey key: String) async throws
    func exists(forKey key: String) async -> Bool
    func clearAll() async throws
}
