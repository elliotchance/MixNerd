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
    targets: [
        .executableTarget(
            name: "MixNerd",
            path: "Sources/MixNerd",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
