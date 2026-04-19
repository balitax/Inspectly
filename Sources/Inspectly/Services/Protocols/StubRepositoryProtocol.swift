//
//  StubRepositoryProtocol.swift
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

// MARK: - Stub Repository Protocol

public protocol StubRepositoryProtocol {
    func getAllStubs() async -> [RequestStub]
    func getStub(by id: UUID) async -> RequestStub?
    func addStub(_ stub: RequestStub) async
    func updateStub(_ stub: RequestStub) async
    func deleteStub(_ id: UUID) async
    func toggleStubEnabled(_ id: UUID, enabled: Bool) async
    func deleteAllStubs() async
    func findMatchingStub(for request: NetworkRequest) async -> RequestStub?
    func toggleStub(_ id: UUID, enabled: Bool) async
    func duplicateStub(_ id: UUID) async -> RequestStub?
    func incrementUsageCount(_ id: UUID) async
}