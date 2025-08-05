// swift-tools-version: 6.1
import PackageDescription

let releaseVersion = Context.environment["DARWIN_PRIVATE_FRAMEWORKS_TARGET_RELEASE"].flatMap { Int($0) } ?? 2024
let platforms: [SupportedPlatform] = switch releaseVersion {
    case 2024: [.iOS(.v18), .macOS(.v15), .macCatalyst(.v18), .tvOS(.v18), .watchOS(.v10), .visionOS(.v2)]
    case 2021: [.iOS(.v15), .macOS(.v12), .macCatalyst(.v15), .tvOS(.v15), .watchOS(.v7)]
    default: []
}

let sharedSwiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v5),
]

let package = Package(
    name: "AGDebugKit",
    platforms: platforms,
    products: [
        .library(name: "AGDebugKit", targets: ["AGDebugKit"]),
    ],
    dependencies: [
        .package(path: "../OpenGraph"),
//        .package(url: "https://github.com/OpenSwiftUIProject/OpenGraph.git", exact: "0.0.2"),
        .package(url: "https://github.com/OpenSwiftUIProject/DarwinPrivateFrameworks.git", exact: "0.0.2"),
    ],
    targets: [
        .target(
            name: "AGDebugKit",
            dependencies: [
                .product(name: "AttributeGraph", package: "DarwinPrivateFrameworks"),
            ],
            swiftSettings: sharedSwiftSettings + [
                .enableExperimentalFeature("AccessLevelOnImport"),
                .enableUpcomingFeature("InternalImportsByDefault"),
            ]
        ),
        // A demo app showing how to use AGDebugKit
        .executableTarget(
            name: "DemoApp",
            dependencies: [
                "AGDebugKit",
            ],
            swiftSettings: sharedSwiftSettings
        ),
        // A client sending command to AGDebugServer
        .executableTarget(
            name: "DebugClient",
            dependencies: [
                "AGDebugKit",
                .product(name: "OpenGraphShims", package: "OpenGraph"),
            ],
            swiftSettings: sharedSwiftSettings
        ),
        .testTarget(
            name: "AGDebugKitTests",
            dependencies: ["AGDebugKit"],
            swiftSettings: sharedSwiftSettings
        ),
    ]
)
