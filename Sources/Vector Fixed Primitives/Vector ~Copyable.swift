// Vector ~Copyable.swift
// Extensions for Vector that work with ~Copyable elements.

// MARK: - Unconstrained API (Element: ~Copyable)

extension Vector where Element: ~Copyable {
    /// The fixed dimension.
    @inlinable
    public static var dimension: Int { N }

    /// Borrowing iteration.
    @inlinable
    public func forEach<E: Error>(
        _ body: (
            borrowing Element
        ) throws(E) -> Void
    ) throws(E) {
        for i in 0..<N {
            let slot = Index_Primitives.Index<Element>(Ordinal(UInt(i)))
            try body(_buffer[slot])
        }
    }

    /// Borrowing access at index.
    ///
    /// - Parameter index: The bounded index of the element to access.
    @inlinable
    public func withElement<R, E: Error>(
        at index: Vector.Index,
        _ body: (borrowing Element) throws(E) -> R
    ) throws(E) -> R {
        let slot = Index_Primitives.Index<Element>(index.ordinal)
        return try body(_buffer[slot])
    }
}

// MARK: - Typed Subscript (~Copyable)

extension Vector where Element: ~Copyable {
    /// Accesses the element at the given bounded index.
    ///
    /// - Parameter index: The bounded index of the element to access.
    @inlinable
    public subscript(index: Vector.Index) -> Element {
        _read {
            let slot = Index_Primitives.Index<Element>(index.ordinal)
            yield _buffer[slot]
        }
        _modify {
            let slot = Index_Primitives.Index<Element>(index.ordinal)
            yield &_buffer[slot]
        }
    }
}
