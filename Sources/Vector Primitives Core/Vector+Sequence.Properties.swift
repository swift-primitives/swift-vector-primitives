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

internal import Property_Primitives
public import Sequence_Primitives

// MARK: - Sequence Property Accessors for Vector

extension Vector where Bound: Copyable {

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
}

// MARK: - Sequence Property Accessors for Vector.Reversed

extension Vector.Reversed where Bound: Copyable {

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
}
