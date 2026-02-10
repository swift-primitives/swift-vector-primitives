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
public import Sequence_Primitives

// MARK: - Sequence Property Accessors for Vector

extension Vector where Bound: Copyable {

    /// Access to `.satisfies` operations.
    ///
    /// ```swift
    /// vector.satisfies.all { $0 > 0 }
    /// vector.satisfies.any { $0 == 5 }
    /// vector.satisfies.none { $0 < 0 }
    /// ```
    @inlinable
    public var satisfies: Property<Sequence.Satisfies, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.Satisfies, Self>.View(&self)
        }
    }

    /// Access to `.first` operations.
    ///
    /// ```swift
    /// vector.first { $0 > 5 }  // First element > 5
    /// ```
    @inlinable
    public var first: Property<Sequence.First, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.First, Self>.View(&self)
        }
    }

    /// Returns the count of elements satisfying the predicate.
    ///
    /// ```swift
    /// vector.count(where: { $0 % 2 == 0 })  // Count of even elements
    /// ```
    ///
    /// - Parameter predicate: A closure that takes an element and returns
    ///   `true` if the element should be counted.
    /// - Returns: The number of elements satisfying the predicate.
    ///
    /// - Note: For total count, use the `count` property which is O(1).
    @inlinable
    public func count(where predicate: (Bound) -> Bool) -> Index.Count {
        var count: Index.Count = .zero
        var iterator = makeIterator()
        while let element = iterator.next() {
            if predicate(element) { count += .one }
        }
        return count
    }

    /// Access to `.reduce` operations.
    ///
    /// ```swift
    /// vector.reduce.into(0) { $0 += $1 }
    /// vector.reduce.from(1) { $0 * $1 }
    /// ```
    @inlinable
    public var reduce: Property<Sequence.Reduce, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.Reduce, Self>.View(&self)
        }
    }

    /// Access to `.contains` operations.
    ///
    /// ```swift
    /// vector.contains { $0 == 5 }
    /// ```
    @inlinable
    public var contains: Property<Sequence.Contains, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.Contains, Self>.View(&self)
        }
    }
}

// MARK: - Sequence Property Accessors for Vector.Reversed

extension Vector.Reversed where Bound: Copyable {

    /// Access to `.satisfies` operations.
    ///
    /// ```swift
    /// vector.reversed().satisfies.all { $0 > 0 }
    /// vector.reversed().satisfies.any { $0 == 5 }
    /// vector.reversed().satisfies.none { $0 < 0 }
    /// ```
    @inlinable
    public var satisfies: Property<Sequence.Satisfies, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.Satisfies, Self>.View(&self)
        }
    }

    /// Access to `.first` operations.
    ///
    /// ```swift
    /// vector.reversed().first { $0 > 5 }  // First element > 5 (in reverse order)
    /// ```
    @inlinable
    public var first: Property<Sequence.First, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.First, Self>.View(&self)
        }
    }

    /// Returns the count of elements satisfying the predicate.
    ///
    /// ```swift
    /// vector.reversed().count(where: { $0 % 2 == 0 })  // Count of even elements
    /// ```
    ///
    /// - Parameter predicate: A closure that takes an element and returns
    ///   `true` if the element should be counted.
    /// - Returns: The number of elements satisfying the predicate.
    ///
    /// - Note: For total count, use the `count` property which is O(1).
    @inlinable
    public func count(where predicate: (Bound) -> Bool) -> Vector<Bound>.Index.Count {
        var count: Vector<Bound>.Index.Count = .zero
        var iterator = makeIterator()
        while let element = iterator.next() {
            if predicate(element) { count += .one }
        }
        return count
    }

    /// Access to `.reduce` operations.
    ///
    /// ```swift
    /// vector.reversed().reduce.into(0) { $0 += $1 }
    /// vector.reversed().reduce.from(1) { $0 * $1 }
    /// ```
    @inlinable
    public var reduce: Property<Sequence.Reduce, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.Reduce, Self>.View(&self)
        }
    }

    /// Access to `.contains` operations.
    ///
    /// ```swift
    /// vector.reversed().contains { $0 == 5 }
    /// ```
    @inlinable
    public var contains: Property<Sequence.Contains, Self>.View {
        mutating _read {
            yield unsafe Property<Sequence.Contains, Self>.View(&self)
        }
    }
}
