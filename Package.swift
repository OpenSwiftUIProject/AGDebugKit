// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let releaseVersion = Context.environment["DARWIN_PRIVATE_FRAMEWORKS_TARGET_RELEASE"].flatMap { Int($0) } ?? 2024
let platforms: [SupportedPlatform] = switch releaseVersion {
    case 2024: [.iOS(.v18), .macOS(.v15), .macCatalyst(.v18), .tvOS(.v18), .watchOS(.v10), .visionOS(.v2)]
    case 2021: [.iOS(.v15), .macOS(.v12), .macCatalyst(.v15), .tvOS(.v15), .watchOS(.v7)]
    default: []
}

let package = Package(
    name: "AGDebugKit",
    platforms: platforms,
    products: [
        .library(name: "AGDebugKit", targets: ["AGDebugKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/OpenSwiftUIProject/DarwinPrivateFrameworks.git", exact: "0.0.1"),
        .package(url: "https://github.com/OpenSwiftUIProject/Socket.git", from: "0.3.3"),
    ],
    targets: [
        .target(
            name: "AGDebugKit",
            dependencies: [
                .product(name: "AttributeGraph", package: "DarwinPrivateFrameworks"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
                .enableExperimentalFeature("AccessLevelOnImport"),
            ]
        ),
        // A demo app showing how to use AGDebugKit
        .executableTarget(
            name: "DemoApp",
            dependencies: [
                "AGDebugKit",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
        // A client sending command to AGDebugServer
        .executableTarget(
            name: "DebugClient",
            dependencies: [
                "AGDebugKit",
                .product(name: "Socket", package: "Socket"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
        .testTarget(
            name: "AGDebugKitTests",
            dependencies: ["AGDebugKit"]
        ),
    ]
)
