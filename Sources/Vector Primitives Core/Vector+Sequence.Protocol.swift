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

public import Sequence_Primitives

// MARK: - Conditional IteratorProtocol Conformance
//
// Note: Conditional Copyable conformances for Vector.Iterator and
// Vector.Reversed.Iterator are defined in Vector.swift (same file
// as the type definitions, as required by Swift).

extension Vector.Iterator: IteratorProtocol where Bound: Copyable {}

extension Vector.Iterator: Sequence.Iterator.`Protocol` where Bound: Copyable {
    /// Yields up to `maximumCount` elements as a single-element span.
    @_lifetime(&self)
    @inlinable
    public mutating func nextSpan(maximumCount: Cardinal) -> Swift.Span<Bound> {
        let hasNext = maximumCount > .zero && current < end
        if hasNext {
            _spanValue = transform(current)
            // Index<Bound> += .one resolves to the non-throwing
            // `Ordinal.Protocol.+= (inout Self, Count)` operator.
            current += .one
        }
        let ptr = unsafe withUnsafeMutablePointer(to: &_spanValue) { p in
            unsafe UnsafePointer<Bound>(UnsafeRawPointer(p).assumingMemoryBound(to: Bound.self))
        }
        let s = unsafe Span(_unsafeStart: ptr, count: hasNext ? 1 : 0)
        return unsafe _overrideLifetime(s, mutating: &self)
    }
}

extension Vector.Reversed.Iterator: IteratorProtocol where Bound: Copyable {}

extension Vector.Reversed.Iterator: Sequence.Iterator.`Protocol` where Bound: Copyable {
    /// Yields up to `maximumCount` elements (in reverse order) as a single-element span.
    @_lifetime(&self)
    @inlinable
    public mutating func nextSpan(maximumCount: Cardinal) -> Swift.Span<Bound> {
        let hasNext = maximumCount > .zero && !exhausted
        if hasNext {
            _spanValue = transform(current)
            if current == start {
                exhausted = true
            } else {
                // SAFETY: `current > start >= .zero` proves `current > .zero`,
                // so `current.predecessor.exact()` cannot underflow. The
                // `do/catch` sets `exhausted = true` on the unreachable path.
                do throws(Ordinal.Error) {
                    current = try current.predecessor.exact()
                } catch {
                    exhausted = true
                }
            }
        }
        let ptr = unsafe withUnsafeMutablePointer(to: &_spanValue) { p in
            unsafe UnsafePointer<Bound>(UnsafeRawPointer(p).assumingMemoryBound(to: Bound.self))
        }
        let s = unsafe Span(_unsafeStart: ptr, count: hasNext ? 1 : 0)
        return unsafe _overrideLifetime(s, mutating: &self)
    }
}

// MARK: - Swift.Sequence Conformance

extension Vector: Swift.Sequence where Bound: Copyable {
    /// A lower bound on the number of elements in the sequence.
    @inlinable
    public var underestimatedCount: Int { Int(clamping: count) }
}

extension Vector.Reversed: Swift.Sequence where Bound: Copyable {
    /// A lower bound on the number of elements in the reversed sequence.
    @inlinable
    public var underestimatedCount: Int { Int(clamping: count) }
}

// MARK: - Conditional Sequence.Protocol Conformance for Vector

extension Vector: Sequence.`Protocol` where Bound: Copyable {
    /// The element type produced by iteration.
    public typealias Element = Bound

    /// Returns an iterator over the vector elements.
    ///
    /// This conformance is only available when `Bound: Copyable` because
    /// `Sequence.Protocol.Element` implicitly requires `Copyable` per SE-0427.
    @inlinable
    public borrowing func makeIterator() -> Iterator {
        Iterator(current: start, end: end, transform: transform)
    }
}

// MARK: - Sequence.Clearable for consuming operations

extension Vector: Sequence.Clearable where Bound: Copyable {
    /// Removes all elements by collapsing the vector to empty.
    @inlinable
    public mutating func removeAll() {
        start = end
        count = .zero
    }
}

// MARK: - Conditional Sequence.Protocol Conformance for Vector.Reversed

extension Vector.Reversed: Sequence.`Protocol` where Bound: Copyable {
    /// The element type produced by iteration.
    public typealias Element = Bound

    /// Returns an iterator over the reversed vector elements.
    @inlinable
    public borrowing func makeIterator() -> Iterator {
        Iterator(start: start, end: end, transform: transform)
    }
}

extension Vector.Reversed: Sequence.Clearable where Bound: Copyable {
    /// Removes all elements by collapsing the reversed vector to empty.
    @inlinable
    public mutating func removeAll() {
        start = end
        count = .zero
    }
}
