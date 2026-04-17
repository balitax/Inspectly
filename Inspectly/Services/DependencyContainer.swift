//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation

// MARK: - Dependency Container

/// Central dependency injection container for the Inspectly app.
/// Provides protocol-based injection for all services.
final class DependencyContainer: @unchecked Sendable {

    // MARK: - Singleton

    static let shared = DependencyContainer()

    // MARK: - Services

    let storageManager: StorageManagerProtocol
    let requestRepository: RequestRepositoryProtocol
    let stubRepository: StubRepositoryProtocol
    let exportManager: ExportManagerProtocol
    let networkObserver: NetworkObserverProtocol

    // MARK: - Initialization

    init(
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
