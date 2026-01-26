// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-vector-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "Vector Primitives",
            targets: ["Vector Primitives"]
        )
    ],
    dependencies: [
        .package(path: "../swift-affine-primitives"),
        .package(path: "../swift-algebra-primitives"),
        .package(path: "../swift-bit-primitives"),
        .package(path: "../swift-cyclic-primitives"),
        .package(path: "../swift-dimension-primitives"),
        .package(path: "../swift-finite-primitives"),
        .package(path: "../swift-index-primitives"),
        .package(path: "../swift-ordinal-primitives"),
    ],
    targets: [
        .target(
            name: "Vector Primitives",
            dependencies: [
                .product(name: "Affine Primitives", package: "swift-affine-primitives"),
                .product(name: "Algebra Primitives", package: "swift-algebra-primitives"),
                .product(name: "Bit Primitives", package: "swift-bit-primitives"),
                .product(name: "Cyclic Primitives", package: "swift-cyclic-primitives"),
                .product(name: "Dimension Primitives", package: "swift-dimension-primitives"),
                .product(name: "Finite Primitives", package: "swift-finite-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Ordinal Primitives", package: "swift-ordinal-primitives"),
            ]
        ),
        .testTarget(
            name: "Vector Primitives Tests",
            dependencies: ["Vector Primitives"]
        )
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableExperimentalFeature("Lifetimes"),
        .strictMemorySafety()
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
