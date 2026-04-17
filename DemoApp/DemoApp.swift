//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import SwiftUI
import Alamofire

@main
struct DemoApp: App {
    private let container = DependencyContainer.shared
    
    // Shared alamofire session infused with Inspectly's power
    private let demoSession: Session

    init() {
        // Configure Inspectly's URLProtocol
        InspectlySessionConfiguration.configureURLProtocol(with: container)
        
        // Build an Alamofire session configuration loaded with Inspectly
        var configuration = URLSessionConfiguration.af.default
        InspectlySessionConfiguration.addProtocol(to: &configuration)
        
        // Create the session
        self.demoSession = Session(configuration: configuration)
    }

    var body: some Scene {
        WindowGroup {
            DemoAppView(session: demoSession, container: container)
                .task {
                    // Pre-fill Inspectly with mock stubs so we have something to demonstrate with
                    await loadMockData()
                }
        }
    }
    
    private func loadMockData() async {
        for stub in MockStubs.all {
            await container.stubRepository.addStub(stub)
        }
    }
}
