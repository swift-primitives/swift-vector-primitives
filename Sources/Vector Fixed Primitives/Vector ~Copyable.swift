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
            try unsafe body(_storage.pointer(at: slot).pointee)
        }
    }

    /// Borrowing access at index.
    ///
    /// - Parameter index: The bounded index of the element to access.
    @inlinable
    public func withElement<R, E: Error>(
        at index: Index,
        _ body: (borrowing Element) throws(E) -> R
    ) throws(E) -> R {
        let slot = Index_Primitives.Index<Element>(index.ordinal)
        return try unsafe body(_storage.pointer(at: slot).pointee)
    }

    // MARK: - Span Access

    /// Read-only span of all vector elements.
    ///
    /// Provides zero-copy access to the vector's contiguous storage.
    public var span: Span<Element> {
        @_lifetime(borrow self)
        @inlinable
        borrowing get {
            let ptr = unsafe UnsafePointer(_storage.pointer(at: .zero))
            let span = unsafe Span(_unsafeStart: ptr, count: N)
            return unsafe _overrideLifetime(span, borrowing: self)
        }
    }

    /// Mutable span of all vector elements.
    ///
    /// Provides zero-copy mutable access to the vector's contiguous storage.
    public var mutableSpan: MutableSpan<Element> {
        @_lifetime(&self)
        @inlinable
        mutating get {
            let ptr = unsafe _storage.pointer(at: .zero)
            let span = unsafe MutableSpan(_unsafeStart: ptr, count: N)
            return unsafe _overrideLifetime(span, mutating: &self)
        }
    }
}

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
