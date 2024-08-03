// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "crud-file-manager-swift",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "CRUDFileManager",
            targets: ["CRUDFileManager"]),
    ],
    targets: [
        .target(
            name: "CRUDFileManager",
            path: "Sources/CRUD File Manager"
        ),
        .testTarget(
            name: "CURDFileManagerTests",
            dependencies: ["CRUDFileManager"],
            path: "Tests/CURD File Manager Tests"
        ),
    ]
)
