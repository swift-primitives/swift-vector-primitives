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

extension Vector.Reversed {
    /// Namespace for drop operations on reversed vectors.
    ///
    /// For a reversed vector, dropping skips elements from the high end
    /// (which appears first in iteration order).
    public struct Drop: ~Copyable {
        @usableFromInline
        var base: Vector<Bound>.Reversed

        @inlinable
        init(_ base: Vector<Bound>.Reversed) {
            self.base = base
        }
    }
}

extension Vector.Reversed.Drop where Bound: Copyable {

    /// Skip first N elements (from end): `.drop.first(_:)` → O(1)
    ///
    /// For a reversed vector, this drops from the high end.
    ///
    /// ```swift
    /// let count = try Vector<UInt>.Index.Count(10)
    /// let vector = Vector(count: count) { $0 }.reversed()
    /// vector.drop.first(try .init(3))  // Equivalent to 0..<7 reversed
    /// ```
    @inlinable
    public consuming func first(_ count: Vector<Bound>.Index.Count) -> Vector<Bound>.Reversed {
        let newEnd = base.end.retreat.clamped(by: count, to: base.start)
        return Vector<Bound>.Reversed(__unchecked: (), start: base.start, end: newEnd, transform: base.transform)
    }

    /// Skip elements while predicate is true: `.drop.while { }` → O(n)
    ///
    /// ```swift
    /// let count = try Vector<UInt>.Index.Count(10)
    /// let vector = Vector(count: count) { $0 }.reversed()
    /// vector.drop.while { $0.position > 5 }  // [5, 4, 3, 2, 1, 0]
    /// ```
    @inlinable
    public consuming func `while`(_ predicate: (Bound) -> Bool) -> [Bound] {
        var result: [Bound] = []
        var dropping = true
        guard !base.isEmpty else { return result }

        // Safe: !isEmpty means end > start >= 0, so end > 0
        var i = try! base.end.predecessor.exact()
        while i >= base.start {
            let element = base.transform(i)
            if dropping && predicate(element) {
                if i == base.start { break }
                // Safe: i > start >= 0, so i > 0
                i = try! i.predecessor.exact()
                continue
            }
            dropping = false
            result.append(element)
            if i == base.start { break }
            // Safe: i > start >= 0, so i > 0
            i = try! i.predecessor.exact()
        }
        return result
    }
}

extension Vector.Reversed where Bound: Copyable {

    /// Access to `.drop` operations.
    ///
    /// ```swift
    /// let vector = Vector(count: try .init(10)) { $0 }.reversed()
    /// let dropped = vector.drop.first(try .init(3))  // O(1)
    /// ```
    @inlinable
    public var drop: Drop {
        Drop(self)
    }
}
