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

    /// Takes the first N elements from the end via `.prefix.first(_:)` in O(1).
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

    /// Takes elements while predicate is true via `.prefix.while { }` in O(n).
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

        // SAFETY: `!base.isEmpty` proves `end > start >= .zero`, so
        // `end.predecessor.exact()` cannot underflow. `do/catch` with an
        // early return on the unreachable path replaces `try!`.
        let initial: Vector<Bound>.Index
        do throws(Ordinal.Error) {
            initial = try base.end.predecessor.exact()
        } catch {
            return result
        }
        var i = initial
        while i >= base.start {
            let element = base.transform(i)
            if !predicate(element) { break }
            result.append(element)
            if i == base.start { break }
            // SAFETY: `i > base.start >= .zero` proves `i > .zero`, so
            // `i.predecessor.exact()` cannot underflow. We break on the
            // unreachable path instead of using `try!`.
            do throws(Ordinal.Error) {
                i = try i.predecessor.exact()
            } catch {
                break
            }
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
