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

// MARK: - Initializer from Swift.Range<Index>

extension Vector {
    /// Creates a vector from a `Swift.Range` of typed indices.
    ///
    /// This initializer enables iteration over `Swift.Range<Index<Tag>>` using
    /// the `Vector` iteration patterns:
    ///
    /// ```swift
    /// let range: Swift.Range<Index<Element>> = startIndex..<endIndex
    /// Vector(range).forEach { index in
    ///     process(elements[index])
    /// }
    /// ```
    ///
    /// - Parameter range: A Swift range of typed indices.
    @inlinable
    public init<Tag: ~Copyable>(
        _ range: Swift.Range<Index_Primitives.Index<Tag>>
    ) where Bound == Index_Primitives.Index<Tag> {
        let start: Vector<Bound>.Index = range.lowerBound.retag()
        let end: Vector<Bound>.Index = range.upperBound.retag()
        // Swift.Range guarantees lowerBound <= upperBound, so no validation needed
        self.init(
            __unchecked: (),
            start: start,
            end: end,
            transform: { $0.retag() }
        )
    }
}

// MARK: - Typed Subscript for Index Bounds

extension Vector {
    /// Returns the index at the given typed offset from start.
    ///
    /// This subscript uses `Index<Tag>.Offset` for type-safe access when
    /// the bound type is `Index<Tag>`.
    ///
    /// This is a **generative** subscript: each access calls the transform
    /// function and produces a fresh `Index<Tag>` value. No caching occurs.
    ///
    /// - Important: The offset must be non-negative and less than `count`.
    ///   Repeated subscripting at the same offset regenerates the value.
    ///
    /// - Precondition: `offset >= 0 && offset < count`
    @inlinable
    public subscript<Tag: ~Copyable>(offset: Index_Primitives.Index<Tag>.Offset) -> Index_Primitives.Index<Tag>
    where Bound == Index_Primitives.Index<Tag> {
        precondition(offset >= .zero, "Offset must be non-negative")
        precondition(offset.vector < count, "Offset out of bounds")
        // Convert the Tag offset to a Vector offset for internal arithmetic
        let vectorOffset = Vector<Bound>.Index.Offset(offset.vector)
        let position = try! start + vectorOffset  // Safe: precondition ensures non-negative result
        return transform(position)
    }
}

// MARK: - Typed Subscript for Reversed Index Bounds

extension Vector.Reversed {
    /// Returns the index at the given typed offset from the reversed start.
    ///
    /// - Important: This regenerates the value; no caching occurs.
    /// - Precondition: `offset >= 0 && offset < count`
    @inlinable
    public subscript<Tag: ~Copyable>(offset: Index_Primitives.Index<Tag>.Offset) -> Index_Primitives.Index<Tag>
    where Bound == Index_Primitives.Index<Tag> {
        precondition(offset >= .zero, "Offset must be non-negative")
        precondition(offset.vector < count, "Offset out of bounds")
        // Convert offset to Vector.Index arithmetic
        // Reversed subscript: end - 1 - offset
        // Safe: precondition ensures count > 0, so end > start, so end > 0
        let lastIndex = try! end.predecessor.exact()
        let vectorOffset = Vector<Bound>.Index.Offset(offset.vector)
        let position = try! lastIndex - vectorOffset  // Safe: precondition ensures valid
        return transform(position)
    }
}
