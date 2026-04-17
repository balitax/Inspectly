// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Inspectly",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Inspectly",
            targets: ["Inspectly"]
        ),
    ],
    targets: [
        .target(
            name: "Inspectly",
            path: "Sources/Inspectly"
        ),
        .testTarget(
            name: "InspectlyTests",
            dependencies: ["Inspectly"],
            path: "Tests/InspectlyTests"
        ),
    ]
)