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
    /// Namespace for drop operations on vectors.
    ///
    /// Provides O(1) `first(_:)` by adjusting bounds directly, and O(n) `while { }`
    /// which must iterate to find the first non-matching element.
    public struct Drop: ~Copyable {
        @usableFromInline
        var base: Vector<Bound>

        @inlinable
        init(_ base: Vector<Bound>) {
            self.base = base
        }
    }
}

extension Vector.Drop where Bound: Copyable {

    /// Skip first N elements: `.drop.first(_:)` → O(1)
    ///
    /// Returns a new vector with adjusted start bound.
    ///
    /// ```swift
    /// let count = try Vector<UInt>.Index.Count(10)
    /// let vector = Vector(count: count) { $0 }
    /// vector.drop.first(try .init(3))  // Vector(3..<10)
    /// ```
    @inlinable
    public consuming func first(
        _ count: Vector<Bound>.Index.Count
    ) -> Vector<Bound> {
        let newStart = base.start.advance.clamped(by: count, to: base.end)
        return Vector<Bound>(
            __unchecked: (),
            start: newStart,
            end: base.end,
            transform: base.transform
        )
    }

    /// Skip elements while predicate is true: `.drop.while { }` → O(n)
    ///
    /// Must iterate to find first non-matching element.
    /// Returns array (cannot compute new bounds without iteration).
    ///
    /// ```swift
    /// let vector = Vector(count: try .init(10)) { $0 }
    /// vector.drop.while { $0.position < 5 }  // [5, 6, 7, 8, 9]
    /// ```
    @inlinable
    public consuming func `while`(_ predicate: (Bound) -> Bool) -> [Bound] {
        var result: [Bound] = []
        var dropping = true
        var i = base.start
        while i < base.end {
            let element = base.transform(i)
            if dropping && predicate(element) {
                // Proof: i < end, so i + 1 <= end
                i += .one
                continue
            }
            dropping = false
            result.append(element)
            // Proof: i < end, so i + 1 <= end
            i += .one
        }
        return result
    }
}

extension Vector where Bound: Copyable {

    /// Access to `.drop` operations with O(1) `first(_:)`.
    ///
    /// ```swift
    /// let count = try Vector<UInt>.Index.Count(10)
    /// let vector = Vector(count: count) { $0 }
    /// let dropped = vector.drop.first(try .init(3))  // O(1) → Vector(3..<10)
    /// ```
    @inlinable
    public var drop: Drop {
        Drop(self)
    }
}
