// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-vector-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Vector Primitives",
            targets: ["Vector Primitives"]
        ),
        .library(
            name: "Vector Primitives Test Support",
            targets: ["Vector Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-index-primitives"),
        .package(path: "../swift-cyclic-primitives"),
        .package(path: "../swift-property-primitives"),
        .package(path: "../swift-sequence-primitives"),
    ],
    targets: [
        .target(
            name: "Vector Primitives Core",
            dependencies: [
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Cyclic Primitives", package: "swift-cyclic-primitives"),
                .product(name: "Property Primitives", package: "swift-property-primitives"),
                .product(name: "Sequence Primitives", package: "swift-sequence-primitives"),
            ]
        ),
        .target(
            name: "Vector Primitives Standard Library Integration",
            dependencies: [
                "Vector Primitives Core",
            ]
        ),
        .target(
            name: "Vector Primitives",
            dependencies: [
                "Vector Primitives Core",
                "Vector Primitives Standard Library Integration",
            ]
        ),
        .target(
            name: "Vector Primitives Test Support",
            dependencies: [
                "Vector Primitives",
                .product(name: "Index Primitives Test Support", package: "swift-index-primitives"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Vector Primitives Tests",
            dependencies: [
                "Vector Primitives",
                "Vector Primitives Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableExperimentalFeature("Lifetimes"),
        .strictMemorySafety(),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
