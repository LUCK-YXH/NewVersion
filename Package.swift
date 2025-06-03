// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NewVersion",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "NewVersion",
            targets: ["NewVersion"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.7.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "NewVersion",
            dependencies: ["SnapKit"],
            path: "Sources/NewVersion", // 建议指定路径，便于管理
            resources: [
                .process("en.lproj"),
                .process("zh-Hans.lproj")
            ]
        ),
        .testTarget(
            name: "NewVersionTests",
            dependencies: ["NewVersion"]
        ),
    ]
)
