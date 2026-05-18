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

    /// Skips the first N elements from the end via `.drop.first(_:)` in O(1).
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

    /// Skips elements while predicate is true via `.drop.while { }` in O(n).
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
            if dropping && predicate(element) {
                if i == base.start { break }
                // SAFETY: `i > base.start >= .zero` proves `i > .zero`,
                // so `i.predecessor.exact()` cannot underflow. We break on
                // the unreachable path instead of using `try!`.
                do throws(Ordinal.Error) {
                    i = try i.predecessor.exact()
                } catch {
                    break
                }
                continue
            }
            dropping = false
            result.append(element)
            if i == base.start { break }
            // SAFETY: `i > base.start >= .zero` proves `i > .zero`,
            // so `i.predecessor.exact()` cannot underflow. We break on
            // the unreachable path instead of using `try!`.
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
