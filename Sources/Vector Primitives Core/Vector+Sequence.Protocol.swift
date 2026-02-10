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

extension Vector.Reversed.Iterator: IteratorProtocol where Bound: Copyable {}

// MARK: - Swift.Sequence Conformance

extension Vector: Swift.Sequence where Bound: Copyable {
    @inlinable
    public var underestimatedCount: Int { Int(clamping: count) }
}

extension Vector.Reversed: Swift.Sequence where Bound: Copyable {
    @inlinable
    public var underestimatedCount: Int { Int(clamping: count) }
}

// MARK: - Conditional Sequence.Protocol Conformance for Vector

extension Vector: Sequence.`Protocol` where Bound: Copyable {
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
    @inlinable
    public mutating func removeAll() {
        start = end
        count = .zero
    }
}

// MARK: - Conditional Sequence.Protocol Conformance for Vector.Reversed

extension Vector.Reversed: Sequence.`Protocol` where Bound: Copyable {
    public typealias Element = Bound

    /// Returns an iterator over the reversed vector elements.
    @inlinable
    public borrowing func makeIterator() -> Iterator {
        Iterator(start: start, end: end, transform: transform)
    }
}

extension Vector.Reversed: Sequence.Clearable where Bound: Copyable {
    @inlinable
    public mutating func removeAll() {
        start = end
        count = .zero
    }
}
