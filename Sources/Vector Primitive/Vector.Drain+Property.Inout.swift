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

// The two `callAsFunction(_:)` overloads below dispatch on disjoint `Base`
// constraints (`Vector<Bound>` vs `Vector<Bound>.Reversed`), so the Swift
// compiler resolves them unambiguously by type context. The
// `swift-format-ignore` directive on the extension suppresses the lint-time
// `AmbiguousTrailingClosureOverload` warning, which inspects names only.
// swift-format-ignore: AmbiguousTrailingClosureOverload
/// Property.Inout extensions for consuming iteration on `Vector`.
///
/// Uses method-level constraints (`where Tag == Vector<Bound>.Drain`) rather
/// than extension-level constraints, since `Vector<Bound>.Drain` requires
/// introducing `Bound` as a method-level generic parameter.
extension Property.Inout where Base: ~Copyable {

    /// Consuming iteration via `.drain { }`.
    @inlinable
    public mutating func callAsFunction<Bound: ~Copyable>(
        _ body: (consuming Bound) -> Void
    ) where Tag == Vector<Bound>.Drain, Base == Vector<Bound> {
        base.value._consumingDrain(body)
    }

    /// Consuming iteration on reversed vector via `.drain { }`.
    @inlinable
    public mutating func callAsFunction<Bound: ~Copyable>(
        _ body: (consuming Bound) -> Void
    ) where Tag == Vector<Bound>.Drain, Base == Vector<Bound>.Reversed {
        base.value._consumingDrain(body)
    }
}
