# Inspectly

[![iOS](https://img.shields.io/badge/iOS-13.0%2B-blue)](https://developer.apple.com)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![SPM](https://img.shields.io/badge/SPM-Ready-purple)](https://swift.org/package-manager)

Inspectly is a zero-dependency HTTP inspector and stubbing toolkit for iOS. It captures network traffic automatically, provides an in-app inspector UI, and lets you create and manage API stubs directly from the requests your app makes.

It is designed to work with the Foundation networking stack, so it fits naturally with `URLSession`, Alamofire, AFNetworking, and other libraries built on top of them.

## Highlights

- Zero configuration request interception via `URLProtocol` registration and swizzling.
- Zero external dependencies.
- Request capture for headers, bodies, response metadata, and timing.
- In-app inspector with tabs for Requests, Statistics, Stubs, and Settings.
- Create a stub directly from a captured request.
- Enable, disable, duplicate, delete, search, filter, and clear stubs from the UI.
- Search, sort, filter, pin, favorite, delete, and clear captured requests.
- Stub badge support in the request list for requests linked to stubs.
- Export logs and stubs from the Settings tab.
- Shake gesture shortcut to open the inspector.

## Requirements

- iOS 13.0+
- Swift 5.9+
- Xcode 15+

Notes:
- Request interception and core storage work on iOS 13+.
- The built-in inspector UI requires iOS 16+.

## Installation

### Swift Package Manager

Add Inspectly to your project:

```swift
dependencies: [
    .package(url: "https://github.com/balitax/Inspectly.git", from: "1.0.4")
]
```

Then add `Inspectly` to your target dependencies.

## Quick Start

### Basic setup

Enable Inspectly once during app startup:

```swift
import Inspectly

@main
struct MyApp: App {
    init() {
        Inspectly.enable()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Present the inspector manually

You can also open the inspector from any button, debug menu, or custom gesture:

```swift
Inspectly.presentInspector()
```

### Recommended debug-only setup

For most apps, it makes sense to enable Inspectly only for debug builds:

```swift
import Inspectly

@main
struct MyApp: App {
    init() {
        #if DEBUG
        Inspectly.enable()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## Configuration

Inspectly can be enabled with a custom configuration:

```swift
import Inspectly

let configuration = Inspectly.Configuration(
    isLoggingEnabled: true,
    isStubEnabled: true,
    ignoredHosts: ["example.com"],
    isShakeGestureEnabled: true,
    ignoreLocalhost: true
)

Inspectly.enable(with: configuration)
```

Available configuration options:

- `isLoggingEnabled`: Enable or disable request capture.
- `isStubEnabled`: Enable or disable request stubbing globally.
- `ignoredHosts`: Skip selected hosts from being captured.
- `isShakeGestureEnabled`: Open the inspector by shaking the device.
- `ignoreLocalhost`: Automatically ignore `localhost` and `127.0.0.1`.
- `stubRepository`: Provide a custom stub repository implementation.

Useful public APIs:

- `Inspectly.enable(isEnabled:with:)`
- `Inspectly.disable()`
- `Inspectly.presentInspector(rootView:)`
- `Inspectly.isEnabled`
- `Inspectly.container`

## What You Get

### Requests

The Requests tab is focused on day-to-day traffic inspection:

- Automatic request and response capture.
- Search by URL, method, or status.
- Sort and filter captured traffic.
- Grouping by date for easier browsing.
- Swipe actions for pin, favorite, and delete.
- Clear all captured requests from the toolbar.
- Request rows can show a stub badge when linked to a stub.

### Request Detail

Each request can be inspected in more depth:

- Overview for request metadata.
- Headers and parameters inspection.
- Request and response body viewing.
- Timeline-style debugging information.
- Create a new stub directly from a live request.

### Statistics

The Statistics tab gives a quick read on app networking activity:

- Total requests summary.
- Error and success visibility.
- Stubbed request count.
- Pinned and favorite request counts.
- Recent activity overview.
- Hourly activity chart.

### Stubs

The Stubs tab helps you manage mocked responses directly inside the app:

- Create and edit stubs.
- Enable or disable a stub without deleting it.
- Duplicate existing stubs.
- Delete individual stubs.
- Clear all stubs from the toolbar.
- Search by stub name or URL rule.
- Filter by active state and HTTP method.
- Automatically unmark linked requests when a stub is removed.

### Settings

The Settings tab centralizes runtime controls and data management:

- Toggle logging on or off.
- Toggle stubs globally.
- Manage ignored hosts.
- Configure max stored requests.
- Enable or disable shake-to-open.
- Toggle JSON prettifying.
- Toggle large body truncation.
- Clear all captured logs.
- Export logs.
- Export stubs.

## Compatibility

Inspectly is built around the Foundation networking stack, so it works with:

- `URLSession`
- Alamofire
- AFNetworking
- Other networking libraries built on top of Foundation

No custom interceptor setup is required for the common use case.

## Screenshots

This section is intentionally prepared so screenshots can be added later without changing the README structure.

### Demo App

| Requests Tab | Request Detail |
| --- | --- |
| <img src="https://raw.githubusercontent.com/balitax/Inspectly/main/Screenshots/request.png" width="300" /> | <img src="https://raw.githubusercontent.com/balitax/Inspectly/main/Screenshots/response.png" width="300" /> |

| Statistics Tab | Stubs Tab | Settings Tab |
| --- | --- | --- |
| <img src="https://raw.githubusercontent.com/balitax/Inspectly/main/Screenshots/statistics.png" width="300" /> | <img src="https://raw.githubusercontent.com/balitax/Inspectly/main/Screenshots/stubs.png" width="300" /> | <img src="https://raw.githubusercontent.com/balitax/Inspectly/main/Screenshots/setting.png" width="300" /> |


## Example Workflow

One practical workflow with Inspectly looks like this:

1. Enable Inspectly in your app.
2. Run the app and trigger real API calls.
3. Open the inspector using shake gesture or `Inspectly.presentInspector()`.
4. Open a request from the Requests tab.
5. Create a stub from that request.
6. Go to the Stubs tab and fine-tune the mocked response.
7. Re-run the same app flow with stubs enabled.

## Contributing

Contributions are welcome. If you want to improve the UI, add features, or fix bugs, feel free to open a pull request.

## License

Inspectly is available under the MIT license. See [LICENSE](LICENSE) for details.

Created by [Agus Cahyono](https://github.com/balitax)
