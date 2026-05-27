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

public import Iterable
public import Sequence_Primitives
public import Vector_Primitive

// This ops module owns the Copyable-imposing iteration conformances for `Vector`
// and `Vector.Reversed`, isolated here per [MOD-004]/[MOD-036]. `Vector` is a
// SCALAR generator (each element is produced on demand by the transform function;
// there is no contiguous span backing), so its iterators are hand-written scalar
// cursors conforming to `Iterator_Primitive.Iterator.`Protocol`` (the foundation
// `next()`-based protocol) — NOT the span-based iterator family.
//
// A single `borrowing makeIterator()` (the type module's `_makeSequenceIterator`
// package window) satisfies BOTH `Iterable` (borrowing requirement) and
// `Sequenceable` (consuming requirement, pulled in by `Sequence.Clearable`):
// a borrowing witness satisfies a consuming protocol requirement. The two
// attachables share the one `Iterator` associated-type binding, so NO
// `@_implements` split is needed (the slab pattern).

// MARK: - Iterator.Protocol / IteratorProtocol Conformances
//
// The scalar `next()` is declared `public` in the type module (Vector.swift);
// these conformances bind the iterators to the foundation `Iterator.`Protocol``
// and to `Swift.IteratorProtocol` so they vend through both surfaces.

extension Vector.Iterator: Iterator_Primitive.Iterator.`Protocol`, IteratorProtocol where Bound: Copyable {}

extension Vector.Reversed.Iterator: Iterator_Primitive.Iterator.`Protocol`, IteratorProtocol where Bound: Copyable {}

// MARK: - Shared borrowing makeIterator (satisfies Iterable AND Sequenceable)

extension Vector where Bound: Copyable {
    /// Returns an iterator over the vector elements.
    ///
    /// One borrowing factory satisfies both `Iterable` (multipass, borrowing) and
    /// `Sequenceable` (single-pass, consuming) — a borrowing witness fulfils a
    /// consuming requirement. Reaches the lean type module's storage through the
    /// `_makeSequenceIterator` package window ([MOD-004]/[MOD-036]).
    ///
    /// Only available when `Bound: Copyable` because `Iterable.Iterator` /
    /// `Sequenceable.Iterator` must conform to a `Copyable`-yielding iterator
    /// protocol per SE-0427.
    @inlinable
    public borrowing func makeIterator() -> Iterator {
        _makeSequenceIterator()
    }
}

extension Vector.Reversed where Bound: Copyable {
    /// Returns an iterator over the reversed vector elements.
    ///
    /// One borrowing factory satisfies both `Iterable` and `Sequenceable`
    /// (see `Vector.makeIterator()`). Reaches the lean type module's storage
    /// through the `_makeSequenceIterator` package window.
    @inlinable
    public borrowing func makeIterator() -> Iterator {
        _makeSequenceIterator()
    }
}

// MARK: - Iterable (multipass, borrowing attachable)

extension Vector: Iterable where Bound: Copyable {
    /// The element type produced by iteration.
    public typealias Element = Bound
}

extension Vector.Reversed: Iterable where Bound: Copyable {
    /// The element type produced by iteration.
    public typealias Element = Bound
}

// MARK: - Sequence.Clearable (rides Sequenceable, the single-pass attachable)

extension Vector: Sequence.Clearable where Bound: Copyable {
    /// Removes all elements by collapsing the vector to empty.
    @inlinable
    public mutating func removeAll() {
        _clear()
    }
}

extension Vector.Reversed: Sequence.Clearable where Bound: Copyable {
    /// Removes all elements by collapsing the reversed vector to empty.
    @inlinable
    public mutating func removeAll() {
        _clear()
    }
}

// MARK: - Swift.Sequence

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
