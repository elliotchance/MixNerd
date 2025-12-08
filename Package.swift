// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MixNerd",
    platforms: [
        .macOS(.v14)   // or .v13 if you need older compatibility
    ],
    products: [
        .executable(
            name: "MixNerd",
            targets: ["MixNerd"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/chicio/ID3TagEditor.git", from: "5.0.0")
    ],
    targets: [
        .executableTarget(
            name: "MixNerd",
            dependencies: ["ID3TagEditor"],
            path: "Sources/MixNerd",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "MixNerdTests",
            dependencies: ["MixNerd"]
        )
    ]
)
