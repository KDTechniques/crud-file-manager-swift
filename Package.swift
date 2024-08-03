// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "crud-file-manager-swift",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "crud-file-manager-swift",
            targets: ["crud-file-manager-swift"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "crud-file-manager-swift"),
        .testTarget(
            name: "crud-file-manager-swiftTests",
            dependencies: ["crud-file-manager-swift"]
        ),
    ]
)
