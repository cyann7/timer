// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "timer",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "timer",
            targets: ["timer"]
        )
    ],
    targets: [
        .target(
            name: "timer"
        ),
        .testTarget(
            name: "timerTests",
            dependencies: ["timer"]
        )
    ],
    swiftLanguageModes: [.v6]
)
