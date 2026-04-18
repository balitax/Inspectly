//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import SwiftUI
import Inspectly

@main
struct DemoApp: App {
    
    init() {
        Inspectly.enable()
    }

    var body: some Scene {
        WindowGroup {
            DemoAppView()
        }
    }
}
