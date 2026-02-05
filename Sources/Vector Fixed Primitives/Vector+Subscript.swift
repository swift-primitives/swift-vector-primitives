// Vector+Subscript.swift
// Subscript access for heap-backed Vector.

// MARK: - Typed Subscript (~Copyable)

extension Vector where Element: ~Copyable {
    /// Accesses the element at the given bounded index.
    ///
    /// - Parameter index: The bounded index of the element to access.
    @inlinable
    public subscript(index: Index) -> Element {
        _read {
            let slot = Index_Primitives.Index<Element>(index.ordinal)
            yield unsafe _storage.pointer(at: slot).pointee
        }
        _modify {
            let slot = Index_Primitives.Index<Element>(index.ordinal)
            yield unsafe &_storage.pointer(at: slot).pointee
        }
    }
}

// MARK: - Typed Subscript (Copyable with CoW)

extension Vector where Element: Copyable {
    /// Accesses the element at the given bounded index with copy-on-write semantics.
    ///
    /// - Parameter index: The bounded index of the element to access.
    @inlinable
    public subscript(index: Index) -> Element {
        _read {
            let slot = Index_Primitives.Index<Element>(index.ordinal)
            yield unsafe _storage.pointer(at: slot).pointee
        }
        _modify {
            _makeUnique()
            let slot = Index_Primitives.Index<Element>(index.ordinal)
            yield unsafe &_storage.pointer(at: slot).pointee
        }
    }
}

// MARK: - Safe Access

extension Vector where Element: Copyable {
    /// Returns the element at the bounded index.
    ///
    /// - Parameter index: The bounded index of the element to access.
    /// - Returns: The element at the index.
    @inlinable
    public func element(at index: Index) -> Element {
        let slot = Index_Primitives.Index<Element>(index.ordinal)
        return unsafe _storage.pointer(at: slot).pointee
    }
}
