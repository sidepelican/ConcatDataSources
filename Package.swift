// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "ConcatDataSources",
    products: [
        .library(name: "ConcatDataSources", targets: ["ConcatDataSources"]),
    ],
    targets: [
        .target(
            name: "ConcatDataSources",
            dependencies: []
        ),
    ]
)
