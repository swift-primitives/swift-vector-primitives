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

/// Property.View extensions for consuming iteration on `Vector`.
///
/// Uses method-level constraints (`where Tag == Vector<Bound>.Drain`) rather
/// than extension-level constraints, since `Vector<Bound>.Drain` requires
/// introducing `Bound` as a method-level generic parameter.
extension Property.View where Base: ~Copyable {

    /// Consuming iteration: `.drain { }`
    @inlinable
    public mutating func callAsFunction<Bound: ~Copyable>(
        _ body: (consuming Bound) -> Void
    ) where Tag == Vector<Bound>.Drain, Base == Vector<Bound> {
        unsafe base.value._consumingDrain(body)
    }

    /// Consuming iteration on reversed vector: `.drain { }`
    @inlinable
    public mutating func callAsFunction<Bound: ~Copyable>(
        _ body: (consuming Bound) -> Void
    ) where Tag == Vector<Bound>.Drain, Base == Vector<Bound>.Reversed {
        unsafe base.value._consumingDrain(body)
    }
}
