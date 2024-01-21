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
        .package(url: "https://github.com/OpenSwiftUIProject/OpenGraph.git", from: "0.0.2"),
    ],
    targets: [
        .executableTarget(
            name: "DemoApp",
            dependencies: [
                "AGDebugKit"
            ]
        ),
        .target(
            name: "AGDebugKit",
            dependencies: [
                .product(name: "AttributeGraph", package: "OpenGraph"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport"),
            ]
        ),
        .testTarget(
            name: "AGDebugKitTests",
            dependencies: ["AGDebugKit"]
        ),
    ]
)
