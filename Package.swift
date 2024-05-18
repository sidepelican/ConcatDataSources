// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "ConcatDataSources",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "ConcatDataSources", targets: ["ConcatDataSources"]),
    ],
    targets: [
        .target(
            name: "ConcatDataSources",
            dependencies: [],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency=complete"),
            ]
        ),
    ]
)
