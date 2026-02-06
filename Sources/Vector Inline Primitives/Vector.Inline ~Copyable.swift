// Vector.Inline ~Copyable.swift
// Extensions for Vector.Inline that work with ~Copyable elements.

// MARK: - Unconstrained (Element: ~Copyable)

extension Vector.Inline where Element: ~Copyable {
    /// The fixed dimension.
    @inlinable
    public static var dimension: Int { N }

    // MARK: - Initialization

    /// Creates a vector by initializing elements via a closure.
    ///
    /// The closure receives a pointer to uninitialized storage and MUST initialize
    /// exactly `N` elements before returning. This is the primary initializer for
    /// `~Copyable` element types.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct Resource: ~Copyable { let id: Int }
    ///
    /// let v = Vector<Resource, 3>.Inline { ptr in
    ///     (ptr + 0).initialize(to: Resource(id: 1))
    ///     (ptr + 1).initialize(to: Resource(id: 2))
    ///     (ptr + 2).initialize(to: Resource(id: 3))
    /// }
    /// ```
    ///
    /// - Parameter initializer: A closure that receives a pointer to uninitialized
    ///   storage and must initialize exactly `N` elements.
    /// - Precondition: The closure must initialize exactly `N` contiguous elements
    ///   starting at the provided pointer.
    @inlinable
    public init(initializing initializer: (UnsafeMutablePointer<Element>) -> Void) {
        var storage = Storage<Element>.Inline<N>()
        let ptr: UnsafeMutablePointer<Element> = unsafe storage.pointer(at: .zero)
        unsafe initializer(ptr)
        storage.initialization = .linear(count: Index_Primitives.Index<Element>.Count(Cardinal(UInt(N))))
        self.init(_storage: storage)
    }


    /// Borrowing iteration.
    @inlinable
    public func forEach<E: Error>(
        _ body: (borrowing Element) throws(E) -> Void
    ) throws(E) {
        for i in 0..<N {
            try body(self[.init(__unchecked: (), .init(UInt(i)))])
        }
    }

    /// Borrowing access at index.
    ///
    /// - Parameter index: The bounded index of the element to access.
    @inlinable
    public func withElement<R, E: Error>(
        at index: Vector<Element, N>.Index,
        _ body: (borrowing Element) throws(E) -> R
    ) throws(E) -> R {
        let slot = Index_Primitives.Index<Element>(index.ordinal)
        return try unsafe body(_storage.pointer(at: slot).pointee)
    }

    // MARK: - Span Access

    /// Read-only span of all vector elements.
    ///
    /// Provides zero-copy access to the vector's contiguous storage.
    /// Elements are ordered from index 0 to N-1.
    @inlinable
    public var span: Span<Element> {
        _read {
            let ptr = unsafe _storage.pointer(at: .zero)
            yield unsafe Span(_unsafeStart: ptr, count: N)
        }
    }

    /// Mutable span of all vector elements.
    ///
    /// Provides zero-copy mutable access to the vector's contiguous storage.
    /// Elements are ordered from index 0 to N-1.
    @inlinable
    public var mutableSpan: MutableSpan<Element> {
        _read {
            let ptr = unsafe UnsafeMutablePointer(mutating: _storage.pointer(at: .zero))
            yield unsafe MutableSpan(_unsafeStart: ptr, count: N)
        }
        _modify {
            var s = unsafe MutableSpan(_unsafeStart: _storage.pointer(at: .zero), count: N)
            yield &s
        }
    }
}
