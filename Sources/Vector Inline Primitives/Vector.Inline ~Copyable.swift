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
        let buffer = Buffer<Element>.Linear.Inline<N>(
            initializingCount: N,
            with: initializer
        )
        self.init(_buffer: buffer)
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
        return try body(_buffer[slot])
    }
}
