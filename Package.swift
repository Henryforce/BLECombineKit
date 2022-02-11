// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BLECombineKit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "BLECombineKit", targets: ["BLECombineKit"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/CombineCommunity/CombineExt.git",
            from: "1.5.1"
        )
    ],
    targets: [
        .target(
            name: "BLECombineKit",
            dependencies: ["CombineExt"],
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
