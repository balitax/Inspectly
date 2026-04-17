# Inspectly

[![iOS](https://img.shields.io/badge/iOS-16.0%2B-blue)](https://developer.apple.com)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![SPM](https://img.shields.io/badge/SPM-Ready-purple)](https://swift.org/package-manager)

> HTTP Inspector & Mock Library for iOS

Inspectly is a powerful HTTP interception and mocking library for iOS. It allows you to capture, inspect, and mock network requests in your iOS applications. Perfect for debugging, testing, and development.

## Features

- **HTTP Interception** - Intercept HTTP/HTTPS requests via URLProtocol or Alamofire interceptor
- **Request Logging** - Capture and record all requests and responses including headers, body, and timing
- **Mock/Stub Engine** - Create stub responses with flexible match rules (method, URL, headers, body)
- **Scenario Testing** - Multiple response scenarios per stub (success, error, timeout variations)
- **Error Simulation** - Simulate various error conditions: timeout, no internet, 401, 403, 404, 500, and more
- **SwiftUI Interface** - Beautiful SwiftUI-based dashboard, request list, detail view, and stub manager
- **Export Options** - Export requests as curl, JSON, or share to files
- **Configurable** - Enable/disable interception, configure ignored hosts, response delays

## Requirements

- iOS 16.0+
- Swift 5.9+
- Alamofire 5.8+ (optional, for Alamofire integration)

## Installation

### Swift Package Manager

```swift
// Add to Package.swift dependencies
.package(url: "https://github.com/balitax/Inspectly.git", from: "1.0.0")
```

## Quick Start

```swift
import Inspectly

// Enable Inspectly (done once in App init)
Inspectly.enable()

// Or with custom configuration
Inspectly.enable(with: Inspectly.Configuration(
    isLoggingEnabled: true,
    isStubEnabled: true,
    isShakeGestureEnabled: true
))
```

## Shake to Inspect

Shake your device or press **⌘+Ctrl+Z** to open the Inspectly dashboard.

## Configuration

### Basic Configuration

```swift
let config = Inspectly.Configuration(
    isLoggingEnabled: true,      // Enable request logging
    isStubEnabled: true,         // Enable stub/mocking
    isShakeGestureEnabled: true, // Enable shake to open inspector
    ignoredHosts: Set(["api.example.com"]), // Ignore specific hosts
    ignoreLocalhost: true       // Ignore localhost requests
)

Inspectly.enable(with: config)
```

### Access Services

```swift
// Access repositories
let requestRepo = Inspectly.container.requestRepository
let stubRepo = Inspectly.container.stubRepository
```

## Mock/Stub Configuration

### Using MockStubs (for testing)

```swift
import Inspectly

// Load mock stubs
for stub in MockStubs.all {
    await Inspectly.container.stubRepository.addStub(stub)
}
```

### Creating Custom Stubs

```swift
import Inspectly

let stub = RequestStub(
    name: "Login Success",
    description: "Mock login response",
    matchRule: StubMatchRule(
        method: .post,
        urlPath: "/auth/login"
    ),
    scenarios: [
        StubScenario(
            name: "Success",
            description: "Success response",
            response: StubResponse(
                statusCode: 200,
                jsonBody: "{\"token\": \"abc123\"}"
            ),
            isActive: true
        )
    ]
)

await Inspectly.container.stubRepository.addStub(stub)
```

## Screenshots

<!-- Add your screenshots here -->

| Dashboard | Request List | Stub Manager |
|-----------|--------------|--------------|
| ![Dashboard](.github/screenshots/dashboard.png) | ![Request List](.github/screenshots/request-list.png) | ![Stub Manager](.github/screenshots/stub-manager.png) |

| Request Detail | Settings |
|----------------|----------|
| ![Request Detail](.github/screenshots/request-detail.png) | ![Settings](.github/screenshots/settings.png) |

## Contributing

Contributions are welcome! Here's how you can help:

### Reporting Bugs

1. Check existing [issues](https://github.com/balitax/Inspectly/issues) first
2. Create a new issue with:
   - Clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - iOS version and device/simulator info

### Suggesting Features

1. Open a discussion or feature request issue
2. Describe the feature and use case
3. Explain why it would be beneficial

### Pull Requests

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/AmazingFeature`)
3. **Follow** Swift coding standards
4. **Test** your changes with the demo app
5. **Commit** using semantic commits:
   - `feat:` - New features
   - `fix:` - Bug fixes
   - `docs:` - Documentation changes
   - `refactor:` - Code refactoring
   - `test:` - Adding or updating tests
6. **Push** to your fork
7. **Create** a Pull Request

### Coding Standards

- Use Swift 5.9+ features where appropriate
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Add documentation for public APIs
- Keep code clean and readable

## License

MIT License - see [LICENSE](LICENSE)

Copyright © 2026 [Agus Cahyono](https://github.com/balitax)
