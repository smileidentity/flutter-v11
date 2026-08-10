// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "smile_id",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        // Flutter consumes the hyphenated product; the underscored one is the Xcode-facing alias.
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
