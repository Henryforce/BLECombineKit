// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BLECombineKit",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(name: "BLECombineKit", targets: ["BLECombineKit"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/CombineCommunity/CombineExt.git",
            from: "1.0.0"
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
            )
    ]
)
