// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "smile_id",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        // Flutter's tool depends on the hyphenated product name; the underscored
        // alias keeps `swift build` and Xcode's package UI usable by name.
        .library(name: "smile-id", targets: ["smile_id"]),
        .library(name: "smile_id", targets: ["smile_id"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/smileidentity/ios.git", exact: "11.2.0")
    ],
    targets: [
        .target(
            name: "smile_id",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "SmileID", package: "ios")
            ]
        )
    ]
)
