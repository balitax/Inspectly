//
//  RequestRepository.swift
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

// MARK: - Request Repository

actor RequestRepository: RequestRepositoryProtocol {
    private var requests: [NetworkRequest]
    private let storageManager: StorageManagerProtocol
    private let storageKey = "inspectly_requests"
    private var maxRequests: Int
    private var lastErrorMessage: String?

    init(
        storageManager: StorageManagerProtocol,
        initialRequests: [NetworkRequest] = [],
        maxRequests: Int = 500
    ) {
        self.storageManager = storageManager
        self.requests = initialRequests
        self.maxRequests = maxRequests
        Task {
            await self.loadFromStorage()
        }
    }

    func getAllRequests() async -> [NetworkRequest] {
        return requests
    }

    func getRequests(offset: Int, limit: Int) async -> [NetworkRequest] {
        guard offset < requests.count else { return [] }
        let end = min(offset + limit, requests.count)
        return Array(requests[offset..<end])
    }

    func getRequest(by id: UUID) async -> NetworkRequest? {
        return requests.first { $0.id == id }
    }

    func addRequest(_ request: NetworkRequest) async {
        requests.insert(request, at: 0)
        // Enforce max storage — trim oldest requests beyond the limit
        if requests.count > maxRequests {
            requests = Array(requests.prefix(maxRequests))
        }
        await persist()
    }

    func setMaxRequests(_ max: Int) async {
        maxRequests = max
        if requests.count > max {
            requests = Array(requests.prefix(max))
            await persist()
        }
    }

    func updateRequest(_ request: NetworkRequest) async {
        if let index = requests.firstIndex(where: { $0.id == request.id }) {
            requests[index] = request
            await persist()
        }
    }

    func deleteRequest(_ id: UUID) async {
        requests.removeAll { $0.id == id }
        await persist()
    }

    func deleteAllRequests() async {
        requests.removeAll()
        await persist()
    }

    func unmarkRequests(for stubId: UUID) async {
        var didChange = false
        for i in 0..<requests.count {
            if requests[i].stubId == stubId {
                requests[i].isStubbed = false
                requests[i].stubId = nil
                didChange = true
            }
        }
        if didChange {
            await persist()
        }
    }

    func markRequestsAsStubbed(for stub: RequestStub) async {
        var didChange = false
        for i in 0..<requests.count {
            if stub.matchRule.matches(requests[i]) {
                requests[i].isStubbed = true
                requests[i].stubId = stub.id
                didChange = true
            }
        }
        if didChange {
            await persist()
        }
    }

    func searchRequests(query: String) async -> [NetworkRequest] {
        guard !query.isEmpty else { return requests }
        let lowercasedQuery = query.lowercased()
        return requests.filter { request in
            request.url.lowercased().contains(lowercasedQuery) ||
            request.method.rawValue.lowercased().contains(lowercasedQuery) ||
            request.host.lowercased().contains(lowercasedQuery) ||
            request.path.lowercased().contains(lowercasedQuery) ||
            (request.statusCode.map { String($0) } ?? "").contains(lowercasedQuery)
        }
    }

    func getRequestCount() async -> Int {
        return requests.count
    }

    // MARK: - Persistence

    func getLastError() async -> String? { lastErrorMessage }

    func loadFromStorage() async {
        do {
            if let stored = try await storageManager.load([NetworkRequest].self, forKey: storageKey) {
                self.requests = stored
                self.lastErrorMessage = nil
                await publishRequestsDidChange()
            }
        } catch {
            lastErrorMessage = "Failed to load requests: \(error.localizedDescription)"
            print("[Inspectly] \(lastErrorMessage!)")
        }
    }

    private func persist() async {
        do {
            try await storageManager.save(requests, forKey: storageKey)
            await publishRequestsDidChange()
        } catch {
            lastErrorMessage = "Failed to save requests: \(error.localizedDescription)"
            print("[Inspectly] \(lastErrorMessage!)")
        }
    }

    private func publishRequestsDidChange() async {
        await MainActor.run {
            NotificationCenter.default.post(name: .inspectlyRequestsDidChange, object: nil)
        }
    }
}

// MARK: - Mock Request Repository

actor MockRequestRepository: RequestRepositoryProtocol {
    private var requests: [NetworkRequest]

    init(requests: [NetworkRequest] = []) {
        self.requests = requests
    }

    func getAllRequests() async -> [NetworkRequest] { requests }
    func getRequests(offset: Int, limit: Int) async -> [NetworkRequest] {
        guard offset < requests.count else { return [] }
        return Array(requests[offset..<min(offset + limit, requests.count)])
    }
    func getRequest(by id: UUID) async -> NetworkRequest? { requests.first { $0.id == id } }
    func setMaxRequests(_ max: Int) async {}
    func getLastError() async -> String? { nil }
    func addRequest(_ request: NetworkRequest) async {
        requests.insert(request, at: 0)
        await publishRequestsDidChange()
    }
    func updateRequest(_ request: NetworkRequest) async {
        if let idx = requests.firstIndex(where: { $0.id == request.id }) {
            requests[idx] = request
            await publishRequestsDidChange()
        }
    }
    func deleteRequest(_ id: UUID) async {
        requests.removeAll { $0.id == id }
        await publishRequestsDidChange()
    }
    func deleteAllRequests() async {
        requests.removeAll()
        await publishRequestsDidChange()
    }
    func unmarkRequests(for stubId: UUID) async {
        var didChange = false
        for index in requests.indices {
            if requests[index].stubId == stubId {
                requests[index].isStubbed = false
                requests[index].stubId = nil
                requests[index].stubScenarioName = nil
                didChange = true
            }
        }
        if didChange {
            await publishRequestsDidChange()
        }
    }

    func markRequestsAsStubbed(for stub: RequestStub) async {
        for index in requests.indices {
            if stub.matchRule.matches(requests[index]) {
                requests[index].isStubbed = true
                requests[index].stubId = stub.id
            }
        }
    }
    func searchRequests(query: String) async -> [NetworkRequest] {
        guard !query.isEmpty else { return requests }
        return requests.filter { $0.url.lowercased().contains(query.lowercased()) }
    }
    func getRequestCount() async -> Int { requests.count }

    private func publishRequestsDidChange() async {
        await MainActor.run {
            NotificationCenter.default.post(name: .inspectlyRequestsDidChange, object: nil)
        }
    }
}
