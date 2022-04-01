// swift-tools-version:5.6
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
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", .upToNextMajor(from: "9.1.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "9.0.0")),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "TMDBKit",
            dependencies: [],
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "TMDBKitTests",
            dependencies: [
                "TMDBKit",
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
                .product(name: "Nimble", package: "Nimble"),
            ],
            exclude: ["Info.plist"],
            resources: [.process("Fixtures")]
        ),
    ]
)
