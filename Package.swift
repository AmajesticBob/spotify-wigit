// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SpotifyWidget",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "SpotifyBridgeKit", targets: ["SpotifyBridgeKit"]),
        .executable(name: "SpotifyHarness", targets: ["SpotifyHarness"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SpotifyBridgeKit",
            dependencies: [],
            path: "Sources/SpotifyBridgeKit"
        ),
        .executableTarget(
            name: "SpotifyHarness",
            dependencies: ["SpotifyBridgeKit"],
            path: "Sources/SpotifyHarness"
        ),
        .testTarget(
            name: "SpotifyBridgeKitTests",
            dependencies: ["SpotifyBridgeKit"],
            path: "Tests/SpotifyBridgeKitTests"
        )
    ]
)
