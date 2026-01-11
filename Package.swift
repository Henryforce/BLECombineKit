// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BLECombineKit",
  platforms: [
    .macOS(.v10_15), .iOS(.v13),
  ],
  products: [
    .library(name: "BLECombineKit", targets: ["BLECombineKit"]),
    .library(name: "BLECombineKitMocks", targets: ["BLECombineKitMocks"]),
  ],
  targets: [
    .target(
      name: "BLECombineKit",
      dependencies: [],
      path: "Sources/BLECombineKit"
    ),
    .target(
      name: "BLECombineKitMocks",
      dependencies: ["BLECombineKit"],
      path: "Sources/BLECombineKitMocks"
    ),
    .testTarget(
      name: "BLECombineKitTests",
      dependencies: [
        "BLECombineKit",
        "BLECombineKitMocks",
      ],
      path: "Tests"
    ),
  ]
)
