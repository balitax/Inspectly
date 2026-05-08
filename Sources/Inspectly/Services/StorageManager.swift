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

actor StorageManager: StorageManagerProtocol {
    private let fileManager = FileManager.default
    private let baseDirectory: URL

    init() {
        let fallback = URL(fileURLWithPath: NSTemporaryDirectory())
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? fallback
        baseDirectory = documentsPath.appendingPathComponent("Inspectly", isDirectory: true)

        if !FileManager.default.fileExists(atPath: baseDirectory.path) {
            try? FileManager.default.createDirectory(at: baseDirectory, withIntermediateDirectories: true)
        }
    }

    func save<T: Encodable>(_ data: T, forKey key: String) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        let encoded = try encoder.encode(data)
        let fileURL = baseDirectory.appendingPathComponent("\(key).json")
        try encoded.write(to: fileURL, options: .atomic)
    }

    func load<T: Decodable & Sendable>(_ type: T.Type, forKey key: String) async throws -> T? {
        let fileURL = baseDirectory.appendingPathComponent("\(key).json")
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }

    func delete(forKey key: String) async throws {
        let fileURL = baseDirectory.appendingPathComponent("\(key).json")
        guard fileManager.fileExists(atPath: fileURL.path) else { return }
        try fileManager.removeItem(at: fileURL)
    }

    func exists(forKey key: String) async -> Bool {
        let fileURL = baseDirectory.appendingPathComponent("\(key).json")
        return fileManager.fileExists(atPath: fileURL.path)
    }

    func clearAll() async throws {
        guard fileManager.fileExists(atPath: baseDirectory.path) else { return }
        try fileManager.removeItem(at: baseDirectory)
        try fileManager.createDirectory(at: baseDirectory, withIntermediateDirectories: true)
    }
}

// MARK: - Mock Storage Manager

final class MockStorageManager: StorageManagerProtocol {
    private var store: [String: Data] = [:]

    func save<T: Encodable>(_ data: T, forKey key: String) async throws {
        store[key] = try JSONEncoder().encode(data)
    }

    func load<T: Decodable & Sendable>(_ type: T.Type, forKey key: String) async throws -> T? {
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
