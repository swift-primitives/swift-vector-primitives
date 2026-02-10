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

extension Vector {
    /// Namespace for prefix operations on vectors.
    ///
    /// Provides O(1) `first(_:)` by adjusting bounds directly, and O(n) `while { }`
    /// which must iterate to find the first non-matching element.
    public struct Prefix: ~Copyable {
        @usableFromInline
        var base: Vector<Bound>

        @inlinable
        init(_ base: Vector<Bound>) {
            self.base = base
        }
    }
}

extension Vector.Prefix where Bound: Copyable {

    /// Take first N elements: `.prefix.first(_:)` → O(1)
    ///
    /// Returns a new vector with adjusted end bound.
    ///
    /// ```swift
    /// let count = try Vector<UInt>.Index.Count(10)
    /// let vector = Vector(count: count) { $0 }
    /// vector.prefix.first(try .init(3))  // Vector(0..<3)
    /// ```
    @inlinable
    public consuming func first(
        _ count: Vector<Bound>.Index.Count
    ) -> Vector<Bound> {
        let newEnd = base.start.advance.clamped(by: count, to: base.end)
        // Safe: newEnd is clamped, and base.start <= base.end (invariant), so base.start <= newEnd
        return Vector<Bound>(
            __unchecked: (),
            start: base.start,
            end: newEnd,
            transform: base.transform
        )
    }

    /// Take elements while predicate is true: `.prefix.while { }` → O(n)
    ///
    /// Must iterate to find first non-matching element.
    /// Returns array (cannot compute new bounds without iteration).
    ///
    /// ```swift
    /// let vector = Vector(count: try .init(10)) { $0 }
    /// vector.prefix.while { $0.position < 5 }  // [0, 1, 2, 3, 4]
    /// ```
    @inlinable
    public consuming func `while`(_ predicate: (Bound) -> Bool) -> [Bound] {
        var result: [Bound] = []
        var i = base.start
        while i < base.end {
            let element = base.transform(i)
            if !predicate(element) { break }
            result.append(element)
            // Proof: i < end, so i + 1 <= end
            i += .one
        }
        return result
    }
}

extension Vector where Bound: Copyable {

    /// Access to `.prefix` operations with O(1) `first(_:)`.
    ///
    /// ```swift
    /// let count = try Vector<UInt>.Index.Count(10)
    /// let vector = Vector(count: count) { $0 }
    /// let prefixed = vector.prefix.first(try .init(3))  // O(1) → Vector(0..<3)
    /// ```
    @inlinable
    public var `prefix`: Prefix {
        Prefix(self)
    }
}
