// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IntaleqMaps",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "IntaleqMaps",
            targets: ["IntaleqMaps"]),
    ],
    targets: [
        .target(
            name: "IntaleqMaps",
            dependencies: [],
            path: "Sources/IntaleqMaps"
        ),
        .testTarget(
            name: "IntaleqMapsTests",
            dependencies: ["IntaleqMaps"],
            path: "Tests/IntaleqMapsTests"
        )
    ]
)
