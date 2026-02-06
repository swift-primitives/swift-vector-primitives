// Vector.Inline+Subscript.swift
// Subscript access for inline Vector.

// MARK: - Typed Subscript (Vector.Inline)

extension Vector.Inline where Element: ~Copyable {
    /// Accesses the element at the given bounded index.
    ///
    /// - Parameter index: The bounded index of the element to access.
    @inlinable
    public subscript(index: Vector<Element, N>.Index) -> Element {
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

// MARK: - Safe Access

extension Vector.Inline where Element: Copyable {
    /// Returns the element at the bounded index.
    ///
    /// - Parameter index: The bounded index of the element to access.
    /// - Returns: The element at the index.
    @inlinable
    public func element(at index: Vector<Element, N>.Index) -> Element {
        let slot = Index_Primitives.Index<Element>(index.ordinal)
        return _buffer[slot]
    }
}
