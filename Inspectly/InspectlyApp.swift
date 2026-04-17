//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import SwiftUI

// MARK: - Inspectly App

@main
struct InspectlyApp: App {
    private let container = DependencyContainer.shared

    var body: some Scene {
        WindowGroup {
            DemoAppView()
                .task {
                    // Configure URL Protocol for live interception
                    InspectlySessionConfiguration.configureURLProtocol(with: container)

                    // Load mock data for demo purposes
                    await loadMockData()
                }
        }
    }

    /// Load mock data into repositories for demonstration
    private func loadMockData() async {
        // Add mock requests
        for request in MockRequests.all {
            await container.requestRepository.addRequest(request)
        }

        // Add mock stubs
        for stub in MockStubs.all {
            await container.stubRepository.addStub(stub)
        }
    }
}
