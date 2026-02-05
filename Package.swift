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
        .package(path: "../swift-buffer-primitives"),
        .package(path: "../swift-algebra-modular-primitives"),
        .package(path: "../swift-index-primitives"),
        .package(path: "../swift-equation-primitives"),
        .package(path: "../swift-hash-primitives"),
    ],
    targets: [
        .target(
            name: "Vector Primitives",
            dependencies: [
                .product(name: "Buffer Primitives", package: "swift-buffer-primitives"),
                .product(name: "Algebra Modular Primitives", package: "swift-algebra-modular-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Equation Primitives", package: "swift-equation-primitives"),
                .product(name: "Hash Primitives", package: "swift-hash-primitives"),
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
