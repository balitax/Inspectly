# Inspectly

[![iOS](https://img.shields.io/badge/iOS-13.0%2B-blue)](https://developer.apple.com)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![SPM](https://img.shields.io/badge/SPM-Ready-purple)](https://swift.org/package-manager)

> **Zero-Dependency** HTTP Inspector & Mock Library for iOS.
> Crafted with ❤️ by **Agus Cahyono**.

Inspectly is a premium, developer-first HTTP interception and mocking library for iOS. It captures, inspects, and mocks network requests with **zero configuration** and **zero dependencies**. It works seamlessly with `URLSession`, **Alamofire**, **AFNetworking**, and any other networking library built on top of the Foundation networking stack.

## 🌟 Key Features

- **Seamless Integration** - Automatic interception via method swizzling. No need to pass configurations or add interceptors manually.
- **Zero Dependencies** - Light-weight and standalone. Supports Alamofire & AFNetworking without linking against them.
- **Modern & Legacy Support** - Compatible with **iOS 13.0+**. Enjoy premium SwiftUI features on iOS 16+ with graceful degradation on legacy versions.
- **HTTP Interception** - Deep capture of requests and responses including headers, body, redirects, and timing.
- **Precision Mocking** - Create stubs with strict "Full URL" matching for exact environment-specific testing.
- **Direct JSON Editing** - Edit mock responses directly within the app's UI with built-in JSON validation.
- **Premium SwiftUI UI** - Interactive Statistics, filterable Request List, detailed Timeline view, and a high-performance Stub Manager (Requires iOS 16+).
- **Quick Export & Share** - Share captures as cURL, JSON files, or full exported logs via the system Share Sheet.
- **Zero-Waste Experience** - No dummy data or clutter. Starts clean, focused entirely on your app's network traffic.
- **Developer Experience** - Shake to open, hourly activity charts, and modern design aesthetics with hidden navigation bars for maximum focus.

## 📦 Installation

### Swift Package Manager

Add Inspectly to your project via SPM:

```swift
// In your Package.swift
dependencies: [
    .package(url: "https://github.com/balitax/Inspectly.git", from: "1.0.4")
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
        // Works on iOS 13+, UI Dashboard requires iOS 16+
        Inspectly.enable()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 2. Presenting the Inspector

You can present the inspector manually. Inspectly will automatically check for version compatibility and warn you if the device version is below iOS 16.

```swift
// Trigger from any button or gesture
Inspectly.presentInspector()
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
Mock any API endpoint with surgical precision. Inspectly's stub engine uses strict URL matching ensuring your mocks only trigger when exactly intended.

- **Direct Editing**: Change HTTP status, delays, and JSON response bodies on the fly.
- **JSON Validation**: Built-in validator ensures your mock responses are always valid.
- **Seamless Creation**: Convert any intercepted live request into a stub with one tap from the detail view.

### 📤 Export & Sharing
Extract your data exactly how you need it.
- **cURL**: Perfectly formatted for terminal testing.
- **JSON File**: Share a full request capture as a `.json` file.
- **Bulk Export**: Export your entire log or stub collection via the system share sheet for backup or team sharing.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

Inspectly is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

**Created by [Agus Cahyono](https://github.com/balitax)**
Copyright © 2026 Agus Cahyono. All rights reserved.
