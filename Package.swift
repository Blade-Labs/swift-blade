// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftBlade",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftBlade",
            targets: ["SwiftBlade"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
        .package(url: "https://github.com/fingerprintjs/fingerprintjs-pro-ios", from: "2.4.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftBlade",
            dependencies: [
                .product(name: "FingerprintPro", package: "fingerprintjs-pro-ios"),
                .product(name: "BigInt", package: "BigInt"),
            ],
            exclude: ["JS/JSWrapper.bundle.js.LICENSE.txt"],
            resources: [
                .process("JS/index.html"),
                .process("JS/JSWrapper.bundle.js"),
            ]
        ),
        .testTarget(
            name: "SwiftBladeTests",
            dependencies: ["SwiftBlade"]
        ),
    ]
)
