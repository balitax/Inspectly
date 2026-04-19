//
//  DependencyContainer.swift
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

// MARK: - Dependency Container

/// Central dependency injection container for the Inspectly app.
/// Provides protocol-based injection for all services.
public final class DependencyContainer: @unchecked Sendable {

    // MARK: - Singleton

    public static let shared = DependencyContainer()

    // MARK: - Services

    public let storageManager: StorageManagerProtocol
    public let requestRepository: RequestRepositoryProtocol
    public let stubRepository: StubRepositoryProtocol
    public let exportManager: ExportManagerProtocol
    public let networkObserver: NetworkObserverProtocol

    // MARK: - Initialization

    public init(
        storageManager: StorageManagerProtocol? = nil,
        requestRepository: RequestRepositoryProtocol? = nil,
        stubRepository: StubRepositoryProtocol? = nil,
        exportManager: ExportManagerProtocol? = nil,
        networkObserver: NetworkObserverProtocol? = nil
    ) {
        let storage = storageManager ?? StorageManager()
        self.storageManager = storage
        self.requestRepository = requestRepository ?? RequestRepository(storageManager: storage)
        self.stubRepository = stubRepository ?? StubRepository(storageManager: storage)
        self.exportManager = exportManager ?? ExportManager()
        self.networkObserver = networkObserver ?? NetworkObserverService()
    }

    // MARK: - Mock Container

    static func mock() -> DependencyContainer {
        let storage = MockStorageManager()
        return DependencyContainer(
            storageManager: storage,
            requestRepository: MockRequestRepository(),
            stubRepository: MockStubRepository(),
            exportManager: MockExportManager(),
            networkObserver: MockNetworkObserverService()
        )
    }
}
