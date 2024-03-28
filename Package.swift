// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AGDebugKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "AGDebugKit", targets: ["AGDebugKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/OpenSwiftUIProject/OpenGraph.git", exact: "0.0.8"),
        .package(url: "https://github.com/OpenSwiftUIProject/Socket.git", from: "0.3.3"),
    ],
    targets: [
        .target(
            name: "AGDebugKit",
            dependencies: [
                .product(name: "AttributeGraph", package: "OpenGraph"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport"),
            ]
        ),
        // A demo app showing how to use AGDebugKit
        .executableTarget(
            name: "DemoApp",
            dependencies: [
                "AGDebugKit",
            ]
        ),
        // A client sending command to AGDebugServer
        .executableTarget(
            name: "DebugClient",
            dependencies: [
                "AGDebugKit",
                .product(name: "Socket", package: "Socket"),
            ]
        ),
        .testTarget(
            name: "AGDebugKitTests",
            dependencies: ["AGDebugKit"]
        ),
    ]
)
