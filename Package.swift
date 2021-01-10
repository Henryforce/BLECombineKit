// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BLECombineKit",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(name: "BLECombineKit", targets: ["BLECombineKit"]),
        .library(name: "BLECombineKitMocks", targets: ["BLECombineKitMocks"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BLECombineKit",
            dependencies: [],
            path: ".",
            exclude: [
                "Sources/BLECombineKit.h",
                "Sources/Info.plist",
//                "BLECombineExplorer",
//                "Products",
//                "Frameworks",
//                "Tests"
            ],
            sources: [
                "Sources/Library"
            ]
        ),
        .target(
            name: "BLECombineKitMocks",
            dependencies: ["BLECombineKit"],
            path: ".",
            exclude: [
                "Sources/BLECombineKit.h",
                "Sources/Info.plist",
            ],
            sources: [
                "Sources/Mocks"
            ]
        )
    ]
)
