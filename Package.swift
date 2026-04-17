// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Inspectly",
    platforms: [
        .iOS(16.0)
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
    ]
)