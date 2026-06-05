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

// MARK: - Package windows for the ops-module Iterable / Sequenceable conformances ([MOD-004]/[MOD-036])
//
// The `Vector` (and `Vector.Reversed`) storage internals (`start`, `end`,
// `transform`) and the iterator storage internals (`current`, `end`,
// `transform`, `start`, `exhausted`) are `@usableFromInline internal`, so the
// Copyable-imposing `Iterable` / `Sequenceable` conformances and the `removeAll()`
// method — isolated in the plural `Vector Primitives` ops module per
// [MOD-004] — cannot reach them by source name across the module boundary.
//
// These `package`-scoped windows are the minimal access level that lets the ops
// module (a different module of the same package) construct the borrowing
// iterator and perform the clear operation. They are deliberately NOT public
// (encapsulation preserved) and NOT @usableFromInline internal (an `internal`
// symbol is invisible cross-module). The conformances that use them are cold per
// [MOD-036]; forgoing *their* cross-package inlining is the accepted trade-off.
// Mirrors the `swift-buffer-slab-primitives` package-window pattern.

extension Vector where Bound: ~Copyable {

    /// Borrowing-iterator factory window for the `Iterable` / `Sequenceable` conformances.
    @inlinable
    package borrowing func _makeSequenceIterator() -> Iterator {
        Iterator(current: start, end: end, transform: transform)
    }

    /// Clear window for the `removeAll()` method.
    @inlinable
    package mutating func _clear() {
        start = end
        count = .zero
    }
}

extension Vector.Reversed where Bound: ~Copyable {

    /// Borrowing-iterator factory window for the `Iterable` / `Sequenceable` conformances.
    @inlinable
    package borrowing func _makeSequenceIterator() -> Iterator {
        Iterator(start: start, end: end, transform: transform)
    }

    /// Clear window for the `removeAll()` method.
    @inlinable
    package mutating func _clear() {
        start = end
        count = .zero
    }
}
