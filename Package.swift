// swift-tools-version: 6.3.1

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
        // MARK: - Type module (lean ~Copyable `Vector` type + structural surface;
        //         Copyable-imposing Sequence/Iterator conformances live in the
        //         plural ops module per [MOD-004]/[MOD-036]).
        .library(
            name: "Vector Primitive",
            targets: ["Vector Primitive"]
        ),
        // MARK: - Ops module + [MOD-005] umbrella (owns the Sequence/Iterator
        //         conformances; re-exports the lean type root + SLI).
        .library(
            name: "Vector Primitives",
            targets: ["Vector Primitives"]
        ),
        .library(
            name: "Vector Primitives Standard Library Integration",
            targets: ["Vector Primitives Standard Library Integration"]
        ),
        .library(
            name: "Vector Primitives Test Support",
            targets: ["Vector Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-index-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-property-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-sequence-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-iterator-primitives.git", branch: "main"),
    ],
    targets: [
        // MARK: - Type module — lean `Vector` type + structural index/range surface
        //         + Property.Inout forEach/drain accessors. No Sequence/Iterator
        //         conformances (those impose Copyable per [MOD-004]); drops the
        //         Sequence Primitives dep accordingly.
        .target(
            name: "Vector Primitive",
            dependencies: [
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Property Primitives", package: "swift-property-primitives"),
            ]
        ),
        // MARK: - Standard Library Integration — UnsafePointer + Index extensions
        //         (genuine stdlib interop; re-exports the lean type root).
        .target(
            name: "Vector Primitives Standard Library Integration",
            dependencies: [
                "Vector Primitive",
            ]
        ),
        // MARK: - Ops module + umbrella — owns the Sequence/Iterator conformances
        //         ([MOD-004] constraint isolation); re-exports the lean type root
        //         and SLI per [MOD-005]. Consumers that iterate a `Vector` import
        //         this plural module (SE-0444 MemberImportVisibility).
        .target(
            name: "Vector Primitives",
            dependencies: [
                "Vector Primitive",
                "Vector Primitives Standard Library Integration",
                .product(name: "Sequence Primitives", package: "swift-sequence-primitives"),
                .product(name: "Iterable", package: "swift-iterator-primitives"),
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
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
