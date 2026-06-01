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

/// Creates a vector from an index to a typed count, producing typed indices.
///
/// This operator enables clean iteration patterns with phantom-typed indices:
///
/// ```swift
/// let count = try Index<Element>.Count(10)
///
/// // Iterate over indices 0..<10
/// (.zero..<count).forEach { index in
///     // index is Index<Element>
///     process(storage.read(at: index))
/// }
/// ```
///
/// The returned `Vector` transforms positions into typed indices
/// on-demand, avoiding the need to store `~Copyable` values.
///
/// - Parameters:
///   - lhs: The lower bound (typed index).
///   - rhs: The typed count representing the upper bound.
/// - Returns: A vector that produces `Index<Tag>` values.
@inlinable
public func ..< <Tag: ~Copyable & ~Escapable>(
    lhs: Index<Tag>,
    rhs: Index<Tag>.Count
) -> Vector<Index<Tag>> {
    let start: Vector<Index<Tag>>.Index = lhs.retag()
    let end: Vector<Index<Tag>>.Index = rhs.map(Ordinal.init).retag()
    // Index and Count are both non-negative, and Index < Count is the expected pattern
    // No validation needed - start is always <= end when lhs.position <= rhs (count as position)
    return Vector(
        __unchecked: (),
        start: start,
        end: end,
        transform: { $0.retag() }
    )
}
