//
//  DemoApp.swift
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

import SwiftUI
import Inspectly

@available(iOS 14.0, *)
@main
struct DemoApp: App {
    
    init() {
        Inspectly.enable()
    }

    var body: some Scene {
        WindowGroup {
            if #available(iOS 16.0, *) {
                DemoAppView()
            } else {
                VStack {
                    Text("Inspectly")
                        .font(.title)
                        .bold()
                    Text("Dashboard UI requires iOS 16.0+")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
