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
public import Vector_Primitive

// MARK: - Conditional IteratorProtocol Conformance
//
// Note: Conditional Copyable conformances for Vector.Iterator and
// Vector.Reversed.Iterator are defined in Vector.swift (same file
// as the type definitions, as required by Swift).

extension Vector.Iterator: IteratorProtocol where Bound: Copyable {}

extension Vector.Iterator: Sequence.Iterator.`Protocol` where Bound: Copyable {
    /// Yields up to `maximumCount` elements as a single-element span.
    ///
    /// Delegates to the lean type module's `_nextSpan` package window, which
    /// owns the internal iterator storage ([MOD-004]/[MOD-036]).
    @_lifetime(&self)
    @inlinable
    public mutating func nextSpan(maximumCount: Cardinal) -> Swift.Span<Bound> {
        _nextSpan(maximumCount: maximumCount)
    }
}

extension Vector.Reversed.Iterator: IteratorProtocol where Bound: Copyable {}

extension Vector.Reversed.Iterator: Sequence.Iterator.`Protocol` where Bound: Copyable {
    /// Yields up to `maximumCount` elements (in reverse order) as a single-element span.
    ///
    /// Delegates to the lean type module's `_nextSpan` package window, which
    /// owns the internal iterator storage ([MOD-004]/[MOD-036]).
    @_lifetime(&self)
    @inlinable
    public mutating func nextSpan(maximumCount: Cardinal) -> Swift.Span<Bound> {
        _nextSpan(maximumCount: maximumCount)
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
        _makeSequenceIterator()
    }
}

// MARK: - Sequence.Clearable for consuming operations

extension Vector: Sequence.Clearable where Bound: Copyable {
    /// Removes all elements by collapsing the vector to empty.
    @inlinable
    public mutating func removeAll() {
        _clear()
    }
}

// MARK: - Conditional Sequence.Protocol Conformance for Vector.Reversed

extension Vector.Reversed: Sequence.`Protocol` where Bound: Copyable {
    /// The element type produced by iteration.
    public typealias Element = Bound

    /// Returns an iterator over the reversed vector elements.
    @inlinable
    public borrowing func makeIterator() -> Iterator {
        _makeSequenceIterator()
    }
}

extension Vector.Reversed: Sequence.Clearable where Bound: Copyable {
    /// Removes all elements by collapsing the reversed vector to empty.
    @inlinable
    public mutating func removeAll() {
        _clear()
    }
}
