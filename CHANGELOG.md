# Changelog

All notable changes to Inspectly are documented here.

---

## [1.2.0] – 2026-05-08

### Breaking Changes
- **Minimum iOS raised to 16.0.** Dropped support for iOS 13–15. The inspector UI, all ViewModels, and all Views no longer carry `@available(iOS 15/16, *)` guards.

### New Features
- **Floating Tab Bar** – Custom liquid-glass-inspired tab bar for iOS 16–25 using `ultraThinMaterial`, `matchedGeometryEffect` sliding highlight, and frosted glass close button.
- **Fullscreen Inspector** – Inspector now presents as `.fullScreen` instead of a page sheet for a more immersive debug experience.
- **DemoApp Revamp** – Completely redesigned demo app with card-based layout, 2-column action grid, inline response console, and success/failure status badge.

### Improvements
- **Dark Mode** – Fixed statistics cards not visible in dark mode by switching `SummaryCardView` background from `systemBackground` (black) to `secondarySystemGroupedBackground` (elevated surface).
- **Content Clearance** – Fixed list content covered by floating tab bar using `safeAreaInset(edge: .bottom)` applied directly to each `List`/`ScrollView`.
- **Concurrency** – Converted `StorageManager` from `final class` with `DispatchQueue` to `actor`, eliminating all Sendable warnings and simplifying the implementation.
- **Code Cleanup** – Removed all redundant `@available(iOS 13/14/15/16, *)` annotations (78 lines) across 37 files.
- **Close Button** – Red tinted close button on the floating tab bar for clear visual affordance.
- **`.build/` ignored** – Added `.build/` to `.gitignore` to prevent Swift Package Manager build artifacts from being committed.

### Bug Fixes
- Replaced `safeAreaPadding(.bottom)` (iOS 17+ only) with standard padding.
- Replaced `symbolEffect(.bounce)` (iOS 17+ only) with spring `scaleEffect` animation.
- Fixed dead code: removed unused `isPresented: Binding<Bool>?` parameter from `ContentView.init`.

---

## [1.1.0] – 2026-05-01

### New Features
- **Slow Request Detection** – Configurable threshold (0.5–10s) in Settings. Requests exceeding the threshold show a tortoise indicator and threshold-relative duration color.
- **Extended Search** – Search now covers response body, request body, and error messages in addition to URL, method, and status.
- **Flexible Stub Matching** – Stubs support regex, prefix, suffix, and contains matching rules in addition to exact URL match.
- **Batch Stub Marking** – When a stub is saved, all captured requests with matching URLs are automatically marked as stubbed.
- **Clear All + Stubs** – Clearing all requests also deletes all stubs.
- **Sensitive Header Masking** – Authorization, Cookie, and other sensitive headers are masked by default in the inspector UI.
- **Pagination** – Request list loads in pages with automatic load-more on scroll.
- **Max Storage Limit** – Configurable maximum number of stored requests in Settings.
- **cURL Export** – Export any request as a properly escaped cURL command.
- **Error State UI** – Dedicated error banners and empty states throughout the UI.
- **Validation Feedback** – Stub editor shows inline validation errors.

### Improvements
- Revamped Request List, Request Detail, Statistics, Stubs, and Settings UIs.
- Dark/light mode support with manual override in Settings.
- GitHub Actions CI workflow.
- GitHub Pages landing page.

### Bug Fixes
- Resolved critical crashes, memory leaks, and stub matching bugs.
- Fixed `TextSelectability` type mismatch in `HeadersTabView`.
- Fixed `Color.tertiary` compiler error in `QuickAccessChip`.

---

## [1.0.6] – 2026-04-25

- Simplified `enable()` API with `isEnabled` parameter defaulting to `true`.
- Fixed shake gesture working correctly in both debug and production.
- Removed unused code and compiler warnings.

## [1.0.5] – 2026-04-24

- Added `enabledEnvironments` / `isInspectorUIAccessibleInProduction` configuration options.
- Debug/production environment support.

## [1.0.4] – 2026-04-23

- Renamed `Dashboard` to `Statistics`.
- SPM-only installation, removed CocoaPods support.

## [1.0.3] – 2026-04-22

- Restructured project as a proper Swift Package.
- Made public API accessible for SPM integration.

## [1.0.2] – 2026-04-21

- Initial SPM package separation from DemoApp.

## [1.0.0] – 2026-04-19

- Initial release.
- HTTP request interception via `URLProtocol`.
- Alamofire and AFNetworking swizzling support.
- Request list, detail, stub manager, and settings UI.
- Shake gesture to open inspector.
