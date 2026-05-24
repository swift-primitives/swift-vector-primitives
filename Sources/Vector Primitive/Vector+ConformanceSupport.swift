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

public import Index_Primitives

// MARK: - Package windows for the ops-module Sequence conformances ([MOD-004]/[MOD-036])
//
// The `Vector` Iterator storage internals (`current`, `end`, `transform`,
// `_spanValue`, `start`, `exhausted`) are `@usableFromInline internal`, so the
// Copyable-imposing `Sequence` / `Sequence.Iterator.Protocol` / `Sequence.Clearable`
// conformances — isolated in the plural `Vector Primitives` ops module per
// [MOD-004] — cannot reach them by source name across the module boundary.
//
// These `package`-scoped windows are the minimal access level that lets the ops
// module (a different module of the same package) drive iterator advancement,
// borrowing-iterator construction, and the clear operation. They are deliberately
// NOT public (encapsulation preserved) and NOT @usableFromInline internal (an
// `internal` symbol is invisible cross-module). The conformances that use them
// are cold per [MOD-036]; forgoing *their* cross-package inlining is the accepted
// trade-off. Mirrors the `swift-buffer-linear-primitives` ConformanceSupport
// pattern (`_storage` / `_header` / `_drain` windows).

extension Vector where Bound: ~Copyable {

    /// Borrowing-iterator factory window for the `Sequence.Protocol` conformance.
    @inlinable
    package borrowing func _makeSequenceIterator() -> Iterator {
        Iterator(current: start, end: end, transform: transform)
    }

    /// Clear window for the `Sequence.Clearable` conformance.
    @inlinable
    package mutating func _clear() {
        start = end
        count = .zero
    }
}

extension Vector.Reversed where Bound: ~Copyable {

    /// Borrowing-iterator factory window for the `Sequence.Protocol` conformance.
    @inlinable
    package borrowing func _makeSequenceIterator() -> Iterator {
        Iterator(start: start, end: end, transform: transform)
    }

    /// Clear window for the `Sequence.Clearable` conformance.
    @inlinable
    package mutating func _clear() {
        start = end
        count = .zero
    }
}

extension Vector.Iterator {

    /// Span-advancement window for the `Sequence.Iterator.Protocol` conformance.
    @_lifetime(&self)
    @inlinable
    package mutating func _nextSpan(maximumCount: Cardinal) -> Swift.Span<Bound> {
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

extension Vector.Reversed.Iterator {

    /// Span-advancement window for the `Sequence.Iterator.Protocol` conformance.
    @_lifetime(&self)
    @inlinable
    package mutating func _nextSpan(maximumCount: Cardinal) -> Swift.Span<Bound> {
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
