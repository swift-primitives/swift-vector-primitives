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

public import Property_Primitives

// MARK: - Tag

extension Swift.Range {
    /// Tag type for bound-mapping operations on ranges.
    public enum Map {}
}

// MARK: - Map Accessor

extension Swift.Range {
    /// Accessor for bound-mapping operations on ranges.
    ///
    /// Provides `.map.bounds { }` to transform both bounds of a range.
    ///
    /// ```swift
    /// let intRange: Range<Index<Foo>> = ...
    /// let bitRange = intRange.map.bounds { $0.retag(Bit.self) }
    /// ```
    @inlinable
    public var map: Property<Map, Swift.Range<Bound>> {
        Property(self)
    }
}

// MARK: - Map Methods

extension Property {
    /// Transforms both bounds of a range using the given closure.
    ///
    /// ```swift
    /// let mapped = range.map.bounds { $0.retag(Bit.self) }
    /// ```
    ///
    /// - Parameter transform: A closure that transforms a bound value.
    /// - Returns: A new range with transformed bounds.
    @inlinable
    public func bounds<Bound: Comparable, T: Comparable>(_ transform: (Bound) -> T) -> Swift.Range<T>
    where Tag == Swift.Range<Bound>.Map, Base == Swift.Range<Bound> {
        transform(base.lowerBound) ..< transform(base.upperBound)
    }
}
