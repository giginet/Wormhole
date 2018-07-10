// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Wormhole",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Wormhole",
            targets: ["Wormhole"]),
    ],
    dependencies: [
        .package(url: "https://github.com/antitypical/Result.git", from: "4.0.0"),
        .package(url: "https://github.com/giginet/libjwt-swift.git", .revision("1c7824cafb522031a351ece348af80802f7d93f4")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Wormhole",
            dependencies: ["Result", "JWT"]),
        .testTarget(
            name: "WormholeTests",
            dependencies: ["Wormhole"]),
    ]
)
