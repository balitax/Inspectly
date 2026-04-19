//
//  ExportManager.swift
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

// MARK: - Export Manager

final class ExportManager: ExportManagerProtocol {
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func exportRequests(_ requests: [NetworkRequest]) async throws -> Data {
        let exportData = ExportWrapper(
            version: "1.0",
            exportedAt: Date(),
            type: "requests",
            count: requests.count,
            data: requests
        )
        return try encoder.encode(exportData)
    }

    func exportStubs(_ stubs: [RequestStub]) async throws -> Data {
        let exportData = ExportWrapper(
            version: "1.0",
            exportedAt: Date(),
            type: "stubs",
            count: stubs.count,
            data: stubs
        )
        return try encoder.encode(exportData)
    }

    func exportAsJSON(_ requests: [NetworkRequest]) async throws -> String {
        let data = try encoder.encode(requests)
        return String(data: data, encoding: .utf8) ?? ""
    }

    func generateShareableURL(for request: NetworkRequest) -> URL? {
        // In a real app, this would create a deep link or shared URL
        return URL(string: "inspectly://request/\(request.id.uuidString)")
    }
}

// MARK: - Export Wrapper

private struct ExportWrapper<T: Codable>: Codable {
    let version: String
    let exportedAt: Date
    let type: String
    let count: Int
    let data: T
}

// MARK: - Mock Export Manager

final class MockExportManager: ExportManagerProtocol {
    func exportRequests(_ requests: [NetworkRequest]) async throws -> Data { Data() }
    func exportStubs(_ stubs: [RequestStub]) async throws -> Data { Data() }
    func exportAsJSON(_ requests: [NetworkRequest]) async throws -> String { "[]" }
    func generateShareableURL(for request: NetworkRequest) -> URL? { nil }
}
