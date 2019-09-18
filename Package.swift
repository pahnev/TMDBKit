// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TMDBKit",
    products: [
        .library(
            name: "TMDBKit",
            targets: ["TMDBKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", .branch("feature/spm-support")),
        .package(url: "https://github.com/Quick/Nimble.git", .exact("8.0.2"))
    ],
    targets: [
        .target(
            name: "TMDBKit",
            dependencies: []),
        .testTarget(
            name: "TMDBKitTests",
            dependencies: ["TMDBKit", "OHHTTPStubsSwift", "Nimble"]),
    ]
)
