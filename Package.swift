// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "ConcatDataSources",
    products: [
        .library(
            name: "ConcatDataSources",
            targets: ["ConcatDataSources"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ConcatDataSources",
            dependencies: []),
        .testTarget(
            name: "ConcatDataSourcesTests",
            dependencies: ["ConcatDataSources"]),
    ]
)
