//
//  ExportManagerProtocol.swift
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

// MARK: - Export Manager Protocol

public protocol ExportManagerProtocol {
    func exportRequests(_ requests: [NetworkRequest]) async throws -> Data
    func exportStubs(_ stubs: [RequestStub]) async throws -> Data
    func exportAsJSON(_ requests: [NetworkRequest]) async throws -> String
    func generateShareableURL(for request: NetworkRequest) -> URL?
}
