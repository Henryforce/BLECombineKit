// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BLECombineKit",
    platforms: [
        .macOS(.v10_15), .iOS(.v13),
    ],
    products: [
        .library(name: "BLECombineKit", targets: ["BLECombineKit"])
    ],
    targets: [
        .target(
            name: "BLECombineKit",
            dependencies: [],
            path: "Sources/BLECombineKit"
        ),
        .testTarget(
            name: "BLECombineKitTests",
            dependencies: [
                "BLECombineKit",
            ],
            path: "Tests"
        ),
    ]
)
