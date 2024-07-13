// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BLECombineKit",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .vision(.v1),
    ],
    products: [
        .library(name: "BLECombineKit", targets: ["BLECombineKit"])
    ],
    targets: [
        .target(
            name: "BLECombineKit",
            path: ".",
            exclude: [
                "Source/BLECombineKit.h",
                "Source/Info.plist",
                "BLECombineExplorer",
                "Tests"
            ],
            sources: [
                "Source"
            ]
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
