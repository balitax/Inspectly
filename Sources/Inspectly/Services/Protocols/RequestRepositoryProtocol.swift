//
//  RequestRepositoryProtocol.swift
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

// MARK: - Request Repository Protocol

public protocol RequestRepositoryProtocol {
    func getAllRequests() async -> [NetworkRequest]
    func getRequest(by id: UUID) async -> NetworkRequest?
    func addRequest(_ request: NetworkRequest) async
    func updateRequest(_ request: NetworkRequest) async
    func deleteRequest(_ id: UUID) async
    func deleteAllRequests() async
    func unmarkRequests(for stubId: UUID) async
    func searchRequests(query: String) async -> [NetworkRequest]
    func getRequestCount() async -> Int
}
