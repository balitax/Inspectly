//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation

// MARK: - Dependency Container

/// Central dependency injection container for the Inspectly app.
/// Provides protocol-based injection for all services.
public final class DependencyContainer: @unchecked Sendable {

    // MARK: - Singleton

    static let shared = DependencyContainer()

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
