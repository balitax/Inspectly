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
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0")
    ],
    targets: [
        .target(
            name: "Inspectly",
            path: "Sources/Inspectly",
            dependencies: ["Alamofire"],
            resources: [
                .process("Assets.xcassets")
            ]
        ),
    ]
)