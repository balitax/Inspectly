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

    init(storageManager: StorageManagerProtocol, initialRequests: [NetworkRequest] = []) {
        self.storageManager = storageManager
        self.requests = initialRequests
        Task {
            await self.loadFromStorage()
        }
    }

    func getAllRequests() async -> [NetworkRequest] {
        return requests
    }

    func getRequest(by id: UUID) async -> NetworkRequest? {
        return requests.first { $0.id == id }
    }

    func addRequest(_ request: NetworkRequest) async {
        requests.insert(request, at: 0)
        await persist()
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

    func loadFromStorage() async {
        do {
            if let stored = try await storageManager.load([NetworkRequest].self, forKey: storageKey) {
                self.requests = stored
                await publishRequestsDidChange()
            }
        } catch {
            print("[Inspectly] Failed to load requests: \(error)")
        }
    }

    private func persist() async {
        do {
            try await storageManager.save(requests, forKey: storageKey)
            await publishRequestsDidChange()
        } catch {
            print("[Inspectly] Failed to persist requests: \(error)")
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
    func getRequest(by id: UUID) async -> NetworkRequest? { requests.first { $0.id == id } }
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
