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

// The two `callAsFunction(_:)` overloads (and the two `borrowing(_:)`
// overloads) below dispatch on disjoint `Base` constraints (`Vector<Bound>`
// vs `Vector<Bound>.Reversed`), so the Swift compiler resolves them
// unambiguously by type context. The `swift-format-ignore` directive on the
// extension suppresses the lint-time `AmbiguousTrailingClosureOverload`
// warning, which inspects names only.
// swift-format-ignore: AmbiguousTrailingClosureOverload
/// Property extensions for borrowing iteration on `Vector`.
///
/// These extensions work on owned `Property` (not `.View`) because `forEach`
/// is read-only traversal that doesn't need to mutate the vector. This enables
/// fluent usage on temporaries: `(0..<count).forEach { }`.
///
/// Uses method-level constraints (`where Tag == Vector<Bound>.ForEach`) rather
/// than extension-level constraints, since `Vector<Bound>.ForEach` requires
/// introducing `Bound` as a method-level generic parameter.
extension Property {

    /// Borrowing iteration via `.forEach { }`.
    @inlinable
    public func callAsFunction<Bound: ~Copyable, E: Swift.Error>(
        _ body: (borrowing Bound) throws(E) -> Void
    ) throws(E) where Tag == Vector<Bound>.ForEach, Base == Vector<Bound> {
        var copy = base
        try copy._borrowingForEach(body)
    }

    /// Explicit borrowing iteration via `.forEach.borrowing { }`.
    @inlinable
    public func borrowing<Bound: ~Copyable, E: Swift.Error>(
        _ body: (borrowing Bound) throws(E) -> Void
    ) throws(E) where Tag == Vector<Bound>.ForEach, Base == Vector<Bound> {
        var copy = base
        try copy._borrowingForEach(body)
    }

    /// Borrowing iteration on reversed vector via `.forEach { }`.
    @inlinable
    public func callAsFunction<Bound: ~Copyable, E: Swift.Error>(
        _ body: (borrowing Bound) throws(E) -> Void
    ) throws(E) where Tag == Vector<Bound>.ForEach, Base == Vector<Bound>.Reversed {
        var copy = base
        try copy._borrowingForEach(body)
    }

    /// Explicit borrowing iteration on reversed vector via `.forEach.borrowing { }`.
    @inlinable
    public func borrowing<Bound: ~Copyable, E: Swift.Error>(
        _ body: (borrowing Bound) throws(E) -> Void
    ) throws(E) where Tag == Vector<Bound>.ForEach, Base == Vector<Bound>.Reversed {
        var copy = base
        try copy._borrowingForEach(body)
    }
}
