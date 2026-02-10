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
    /// Namespace for prefix operations on reversed vectors.
    ///
    /// For a reversed vector, prefix takes elements from the high end
    /// (which appears first in iteration order).
    public struct Prefix: ~Copyable {
        @usableFromInline
        var base: Vector<Bound>.Reversed

        @inlinable
        init(_ base: Vector<Bound>.Reversed) {
            self.base = base
        }
    }
}

extension Vector.Reversed.Prefix where Bound: Copyable {

    /// Take first N elements (from end): `.prefix.first(_:)` → O(1)
    ///
    /// For a reversed vector, this takes from the high end.
    ///
    /// ```swift
    /// let count = try Vector<UInt>.Index.Count(10)
    /// let vector = Vector(count: count) { $0 }.reversed()
    /// vector.prefix.first(try .init(3))  // Equivalent to 7..<10 reversed → [9, 8, 7]
    /// ```
    @inlinable
    public consuming func first(_ count: Vector<Bound>.Index.Count) -> Vector<Bound>.Reversed {
        let newStart = base.end.retreat.clamped(by: count, to: base.start)
        return Vector<Bound>.Reversed(__unchecked: (), start: newStart, end: base.end, transform: base.transform)
    }

    /// Take elements while predicate is true: `.prefix.while { }` → O(n)
    ///
    /// ```swift
    /// let count = try Vector<UInt>.Index.Count(10)
    /// let vector = Vector(count: count) { $0 }.reversed()
    /// vector.prefix.while { $0.position > 5 }  // [9, 8, 7, 6]
    /// ```
    @inlinable
    public consuming func `while`(_ predicate: (Bound) -> Bool) -> [Bound] {
        var result: [Bound] = []
        guard !base.isEmpty else { return result }

        // Safe: !isEmpty means end > start >= 0, so end > 0
        var i = try! base.end.predecessor.exact()
        while i >= base.start {
            let element = base.transform(i)
            if !predicate(element) { break }
            result.append(element)
            if i == base.start { break }
            // Safe: i > start >= 0, so i > 0
            i = try! i.predecessor.exact()
        }
        return result
    }
}

extension Vector.Reversed where Bound: Copyable {

    /// Access to `.prefix` operations.
    ///
    /// ```swift
    /// let vector = Vector(count: try .init(10)) { $0 }.reversed()
    /// let prefixed = vector.prefix.first(try .init(3))  // O(1)
    /// ```
    @inlinable
    public var `prefix`: Prefix {
        Prefix(self)
    }
}
