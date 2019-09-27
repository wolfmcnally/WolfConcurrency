// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "WolfConcurrency",
    platforms: [
        .iOS(.v9), .macOS(.v10_13), .tvOS(.v11)
    ],
    products: [
        .library(
            name: "WolfConcurrency",
            targets: ["WolfConcurrency"]),
        ],
    dependencies: [
        .package(url: "https://github.com/wolfmcnally/WolfNumerics", from: "4.0.0"),
        .package(url: "https://github.com/wolfmcnally/WolfFoundation", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "WolfConcurrency",
            dependencies: [
                "WolfNumerics",
                "WolfFoundation"
            ])
        ]
)
