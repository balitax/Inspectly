//
//  StorageManager.swift
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

// MARK: - Storage Manager

final class StorageManager: StorageManagerProtocol {
    private let fileManager = FileManager.default
    private let baseDirectory: URL

    /// Concurrent queue: reads run in parallel, writes use a barrier to serialize.
    private let ioQueue = DispatchQueue(
        label: "com.inspectly.storage.io",
        attributes: .concurrent
    )

    init() {
        let fallback = URL(fileURLWithPath: NSTemporaryDirectory())
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? fallback
        baseDirectory = documentsPath.appendingPathComponent("Inspectly", isDirectory: true)

        if !fileManager.fileExists(atPath: baseDirectory.path) {
            try? fileManager.createDirectory(at: baseDirectory, withIntermediateDirectories: true)
        }
    }

    func save<T: Encodable>(_ data: T, forKey key: String) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        let encoded = try encoder.encode(data)
        let fileURL = baseDirectory.appendingPathComponent("\(key).json")

        // Barrier write: blocks until all concurrent reads finish, then writes exclusively.
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            ioQueue.async(flags: .barrier) {
                do {
                    try encoded.write(to: fileURL, options: .atomic)
                    cont.resume()
                } catch {
                    cont.resume(throwing: error)
                }
            }
        }
    }

    func load<T: Decodable>(_ type: T.Type, forKey key: String) async throws -> T? {
        let fileURL = baseDirectory.appendingPathComponent("\(key).json")

        // Concurrent read: multiple loads can proceed simultaneously.
        return try await withCheckedThrowingContinuation { (cont: CheckedContinuation<T?, Error>) in
            ioQueue.async {
                guard self.fileManager.fileExists(atPath: fileURL.path) else {
                    cont.resume(returning: nil)
                    return
                }
                do {
                    let data = try Data(contentsOf: fileURL)
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    cont.resume(returning: try decoder.decode(T.self, from: data))
                } catch {
                    cont.resume(throwing: error)
                }
            }
        }
    }

    func delete(forKey key: String) async throws {
        let fileURL = baseDirectory.appendingPathComponent("\(key).json")
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            ioQueue.async(flags: .barrier) {
                do {
                    if self.fileManager.fileExists(atPath: fileURL.path) {
                        try self.fileManager.removeItem(at: fileURL)
                    }
                    cont.resume()
                } catch {
                    cont.resume(throwing: error)
                }
            }
        }
    }

    func exists(forKey key: String) async -> Bool {
        let fileURL = baseDirectory.appendingPathComponent("\(key).json")
        return await withCheckedContinuation { cont in
            ioQueue.async {
                cont.resume(returning: self.fileManager.fileExists(atPath: fileURL.path))
            }
        }
    }

    func clearAll() async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            ioQueue.async(flags: .barrier) {
                do {
                    if self.fileManager.fileExists(atPath: self.baseDirectory.path) {
                        try self.fileManager.removeItem(at: self.baseDirectory)
                        try self.fileManager.createDirectory(
                            at: self.baseDirectory,
                            withIntermediateDirectories: true
                        )
                    }
                    cont.resume()
                } catch {
                    cont.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - Mock Storage Manager

final class MockStorageManager: StorageManagerProtocol {
    private var store: [String: Data] = [:]

    func save<T: Encodable>(_ data: T, forKey key: String) async throws {
        store[key] = try JSONEncoder().encode(data)
    }

    func load<T: Decodable>(_ type: T.Type, forKey key: String) async throws -> T? {
        guard let data = store[key] else { return nil }
        return try JSONDecoder().decode(T.self, from: data)
    }

    func delete(forKey key: String) async throws {
        store.removeValue(forKey: key)
    }

    func exists(forKey key: String) async -> Bool {
        store[key] != nil
    }

    func clearAll() async throws {
        store.removeAll()
    }
}
