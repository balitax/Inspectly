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

### CocoaPods

```ruby
# Future: CocoaPods support coming soon
# pod 'Inspectly', '~> 1.0.0'
```

## Quick Start

```swift
import Inspectly

// 1. Register URLProtocol
URLProtocol.registerClass(InspectlyURLProtocol.self)

// 2. Configure (optional)
InspectlyURLProtocol.isLoggingEnabled = true
InspectlyURLProtocol.isStubEnabled = true

// 3. Set stub repository
InspectlyURLProtocol.stubRepository = stubRepository
```

## Integration Guide

### URLSession Integration

```swift
// Option 1: Global registration
URLProtocol.registerClass(InspectlyURLProtocol.self)

// Option 2: Per-session configuration
let config = URLSessionConfiguration.default
config.protocolClasses = [InspectlyURLProtocol.self] + (config.protocolClasses ?? [])
let session = URLSession(configuration: config)

// 3. Set callback for captured requests
InspectlyURLProtocol.onRequestCaptured = { request in
    print("Captured: \(request.method) \(request.url)")
}
```

### Alamofire Integration

```swift
import Alamofire

let interceptor = InspectlyRequestInterceptor(stubRepository: stubRepository)
let eventMonitor = InspectlyEventMonitor()

let session = Session(
    interceptor: interceptor,
    eventMonitors: [eventMonitor]
)
```

## Stub Configuration

### Match Rules

Configure how requests are matched to stubs:

```swift
let matchRule = StubMatchRule(
    method: .get,           // HTTP method to match
    urlPath: "/api/users",  // URL path contains
    queryParameters: [      // Query params must match
        QueryParameter(key: "page", value: "1")
    ],
    headers: [               // Headers must match
        RequestHeader(key: "Authorization", value: "Bearer token")
    ],
    bodyContains: "search"   // Request body contains
)
```

### Scenarios

Create multiple response scenarios per stub:

```swift
let scenarios = [
    StubScenario(
        name: "Success",
        description: "Normal success response",
        response: StubResponse(
            statusCode: 200,
            jsonBody: "{\"success\": true}"
        ),
        isActive: true
    ),
    StubScenario(
        name: "Error",
        description: "Error response",
        response: StubResponse(
            statusCode: 500,
            jsonBody: "{\"error\": \"Internal Server Error\"}"
        ),
        isActive: false
    ),
    StubScenario(
        name: "Timeout",
        description: "Simulate timeout",
        response: StubResponse(
            statusCode: 200,
            responseDelay: 30,
            errorType: .timeout
        ),
        isActive: false
    )
]
```

### Error Types

Available error types for simulation:

| Error Type | Description |
|------------|-------------|
| `.none` | No error (success) |
| `.timeout` | Request timeout |
| `.noInternet` | No internet connection |
| `.unauthorized` | 401 Unauthorized |
| `.forbidden` | 403 Forbidden |
| `.notFound` | 404 Not Found |
| `.internalServerError` | 500 Internal Server Error |
| `.badGateway` | 502 Bad Gateway |
| `.serviceUnavailable` | 503 Service Unavailable |

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
