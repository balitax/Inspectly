// swift-tools-version:5.9

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
            path: "Inspectly"
        ),
        .testTarget(
            name: "InspectlyTests",
            dependencies: ["Inspectly"],
            path: "Tests"
        ),
    ]
)
