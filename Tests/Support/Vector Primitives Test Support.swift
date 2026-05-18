// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import Index_Primitives_Test_Support
public import Vector_Primitives

// MARK: - Vector Convenience Initializer

extension Vector where Bound == UInt {
    /// Creates a vector from a Swift.Range<Int> for testing convenience.
    ///
    /// The transform receives the position as `UInt` for test convenience.
    ///
    /// - Warning: This initializer is for testing only. Production code should
    ///   use the typed `Vector.Index` initializers.
    public init(
        _ range: Swift.Range<UInt>,
        transform: @escaping @Sendable (UInt) -> UInt = { $0 }
    ) {
        // Safe: Swift.Range guarantees upperBound >= lowerBound
        self.init(
            __unchecked: (),
            start: Vector<UInt>.Index(_unchecked: Ordinal(range.lowerBound)),
            end: Vector<UInt>.Index(_unchecked: Ordinal(range.upperBound)),
            transform: { transform($0.position.rawValue) }
        )
    }

    // swiftlint:disable:next workaround_marker_present
    // WORKAROUND: the two test-only convenience inits below trip a SIL
    // assertion in the `MandatoryPerformanceOptimizations` pass (sub-pass
    // `eliminateDeadAllocations`) on the Swift 6.3.2 RELEASE Wasm SDK
    // Embedded target. Guard them out of the Embedded build graph — Test
    // Support is not consumed by Embedded targets.
    // WHY: `@inlinable` init delegating via @Sendable closure into a
    //      stored-closure field hits `isLegalSILType` assertion at
    //      SILType.h:115 during mandatory monomorphization.
    // TRACKING: swift-institute/Issues/swift-issue-embedded-wasm-mandatory-perf-crash/.
    // WHEN TO REMOVE: when the Wasm SDK ships against Swift ≥ 6.4 (the
    //                 bug is already fixed on 6.4-dev nightly Embedded).
    #if !hasFeature(Embedded)
    /// Creates a vector of the given count whose transform projects positions through `.position.rawValue`.
    @inlinable
    public init(
        count: Vector<UInt>.Index.Count,
        transform: @escaping @Sendable (Int) -> Bound = { $0.magnitude }
    ) {
        self.init(count: count, transform: { $0.position.rawValue })
    }

    /// Creates a vector spanning the given start and end indices, projecting positions through `.position.rawValue`.
    public init(
        start: Vector<UInt>.Index,
        end: Vector<UInt>.Index,
        transform: @escaping @Sendable (Int) -> Bound = { $0.magnitude }
    ) throws(Vector<UInt>.Error) {
        try self.init(start: start, end: end, transform: { $0.position.rawValue })
    }
    #endif
}

/// Errors for domain-vector initialization over Int.
public enum VectorTestError: Swift.Error {
    /// The vector count exceeds UInt.max (vector too large for ordinal space).
    case countOverflow
}

extension Vector where Bound == Int {
    /// Creates a vector over an integer domain interval.
    ///
    /// This initializer treats `range` as a **domain interval** (e.g., `-500..<500`),
    /// not as ordinal positions. Internally, ordinal positions `0..<count` are used,
    /// with offset translation to produce domain values.
    ///
    /// - Parameters:
    ///   - range: The integer domain interval.
    ///   - transform: A function applied to each domain value.
    /// - Throws: `VectorTestError.countOverflow` if the vector count exceeds `UInt.max`.
    ///
    /// - Warning: This initializer is for testing only. Production code should
    ///   use the typed `Vector.Index` initializers.
    public init(
        _ range: Swift.Range<Swift.Int>,
        transform: @escaping @Sendable (Swift.Int) -> Swift.Int = { $0 }
    ) throws(VectorTestError) {
        // Calculate count (guaranteed non-negative by Range invariant)
        let distance = range.upperBound - range.lowerBound

        // Check if count fits in UInt (ordinal space)
        guard distance >= .zero, UInt(bitPattern: distance) <= UInt.max else {
            throw .countOverflow
        }
        let count = UInt(distance)

        // Offset translation: ordinal position -> domain value
        let offset = range.lowerBound

        // Safe: start is .zero and end is count, so end >= start
        self.init(
            __unchecked: (),
            start: Vector<Int>.Index(_unchecked: .zero),
            end: Vector<Int>.Index(_unchecked: Ordinal(count)),
            transform: { transform(offset + Swift.Int(bitPattern: $0)) }
        )
    }
}
