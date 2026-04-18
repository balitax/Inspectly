# Inspectly

[![iOS](https://img.shields.io/badge/iOS-16.0%2B-blue)](https://developer.apple.com)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![SPM](https://img.shields.io/badge/SPM-Ready-purple)](https://swift.org/package-manager)

> **Zero-Dependency** HTTP Inspector & Mock Library for iOS

Inspectly is a premium, developer-first HTTP interception and mocking library for iOS. It capture, inspects, and mocks network requests with **zero configuration** and **zero dependencies**. It works seamlessly with `URLSession`, **Alamofire**, **AFNetworking**, and any other networking library that uses Foundation's networking stack.

## 🌟 Key Features

- **Seamless Integration** - Automatic interception via method swizzling. No need to pass configurations or add interceptors manually.
- **Zero Dependencies** - Light-weight and standalone. Supports Alamofire & AFNetworking without linking against them.
- **HTTP Interception** - Deep capture of requests and responses including headers, body, redirects, and timing.
- **Mock/Stub Engine** - Create powerful stubs with flexible match rules and dynamic response scenarios.
- **Error Simulation** - Inject timeouts, connection failures, and HTTP errors to test edge cases.
- **Premium SwiftUI UI** - Interactive Statistics, filterable Request List, detailed Timeline view, and intuitive Stub Manager.
- **Quick Export** - Share requests as cURL commands, raw JSON, or shareable files.
- **Developer Experience** - Shake to open, hourly activity charts, and modern design aesthetics.

## 📦 Installation

### Swift Package Manager

Add Inspectly to your project via SPM:

```swift
// In your Package.swift
dependencies: [
    .package(url: "https://github.com/balitax/Inspectly.git", from: "1.2.0")
]
```

## 🚀 Quick Start

### 1. Initialize Inspectly

Simply enable Inspectly in your `App` or `AppDelegate`. It will automatically begin intercepting requests.

```swift
import Inspectly

@main
struct MyApp: App {
    init() {
        // One-line setup for "magic" interception
        Inspectly.enable()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 2. Custom Configuration

For more control, you can pass a custom configuration:

```swift
let config = Inspectly.Configuration(
    isLoggingEnabled: true,      // Default: true
    isStubEnabled: true,         // Default: false
    isShakeGestureEnabled: true, // Default: true
    ignoredHosts: ["analytics.google.com"],
    ignoreLocalhost: true
)

Inspectly.enable(with: config)
```

## 🛠 Seamless Compatibility

Inspectly uses low-level method swizzling to ensure it catches traffic from any library without you having to write a single line of extra code.

### URLSession
Works automatically for `URLSession.shared` and any custom sessions created with `.default` or `.ephemeral` configurations.

### Alamofire
No need to add `EventMonitor` or `RequestInterceptor`. Just use your `Session` as usual, and Inspectly will catch everything.

### AFNetworking
Works out of the box with `AFHTTPSessionManager` and `AFURLSessionManager`.

## 📱 Features Walkthrough

### 📊 Statistics
Monitor your app's networking health with hourly activity charts, success rates, and method distribution analysis.

### 📋 Request List
Search, filter by status code, and sort your captures. Inspectly groups requests by date for easy navigation.

### 🔍 Request Detail
Dive deep into every request. View headers, formatted JSON bodies, raw data, and a detailed timeline of the network lifecycle.

### 🎭 Stub Manager
Mock any API endpoint. Define match rules for paths, methods, or headers, and switch between success/error scenarios on the fly.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

Inspectly is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

Copyright © 2026 [Agus Cahyono](https://github.com/balitax)
