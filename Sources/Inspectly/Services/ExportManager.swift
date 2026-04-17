//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
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

    func importRequests(from data: Data) async throws -> [NetworkRequest] {
        let wrapper = try decoder.decode(ExportWrapper<[NetworkRequest]>.self, from: data)
        return wrapper.data
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

    func importStubs(from data: Data) async throws -> [RequestStub] {
        let wrapper = try decoder.decode(ExportWrapper<[RequestStub]>.self, from: data)
        return wrapper.data
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
    func importRequests(from data: Data) async throws -> [NetworkRequest] { [] }
    func exportStubs(_ stubs: [RequestStub]) async throws -> Data { Data() }
    func importStubs(from data: Data) async throws -> [RequestStub] { [] }
    func exportAsJSON(_ requests: [NetworkRequest]) async throws -> String { "[]" }
    func generateShareableURL(for request: NetworkRequest) -> URL? { nil }
}
