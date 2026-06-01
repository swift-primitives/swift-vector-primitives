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
    public init<Tag: ~Copyable & ~Escapable>(
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
    public subscript<Tag: ~Copyable & ~Escapable>(offset: Index_Primitives.Index<Tag>.Offset) -> Index_Primitives.Index<Tag>
    where Bound == Index_Primitives.Index<Tag> {
        let vectorOffset: Vector<Bound>.Index.Offset = offset.retag()
        precondition(vectorOffset < count, "Offset out of bounds")
        // SAFETY: precondition above proves `vectorOffset < count`, so
        // `start + vectorOffset` cannot overflow. `do/catch` with `fatalError`
        // on the unreachable path replaces `try!` to satisfy swift-format.
        let position: Vector<Bound>.Index
        do throws(Ordinal.Error) {
            position = try start + vectorOffset
        } catch {
            fatalError("invariant violation: \(error)")
        }
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
    public subscript<Tag: ~Copyable & ~Escapable>(offset: Index_Primitives.Index<Tag>.Offset) -> Index_Primitives.Index<Tag>
    where Bound == Index_Primitives.Index<Tag> {
        let vectorOffset: Vector<Bound>.Index.Offset = offset.retag()
        precondition(vectorOffset < count, "Offset out of bounds")
        // Reversed subscript: end - 1 - offset
        // SAFETY: precondition proves `count > .zero`, so `end > start >= .zero`,
        // so `end > .zero` and `end.predecessor.exact()` cannot underflow.
        // Then `lastIndex - vectorOffset` is guaranteed valid by the precondition.
        // `do/catch` with `fatalError` on the unreachable path replaces `try!`.
        let position: Vector<Bound>.Index
        do throws(Ordinal.Error) {
            let lastIndex = try end.predecessor.exact()
            position = try lastIndex - vectorOffset
        } catch {
            fatalError("invariant violation: \(error)")
        }
        return transform(position)
    }
}
