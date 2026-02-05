// Vector.Inline.swift
// Fixed-size vector with inline storage (zero heap allocation).

// MARK: - Type Declaration

extension Vector where Element: ~Copyable {
    /// Fixed-size vector with inline storage.
    ///
    /// Uses `Storage<Element>.Inline<N>` for zero-allocation stack storage with optimal layout.
    /// Preferred for small dimensions (2, 3, 4) where heap allocation is unnecessary.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let v = Vector<Int, 3>.Inline([1, 2, 3])
    /// print(v[0])  // 1
    /// ```
    ///
    /// ## ~Copyable Support
    ///
    /// `Inline` is ~Copyable by default due to `Storage.Inline` using `@_rawLayout`.
    /// Use `Equation.Protocol` and `Hash.Protocol` for equality/hashing on ~Copyable types.
    ///
    /// ## Memory Layout
    ///
    /// Storage uses `@_rawLayout(likeArrayOf: Element, count: N)` for optimal layout:
    /// - `Vector<Double, 4>.Inline` = 32 bytes (not 256+ like old implementations)
    /// - Elements are stored contiguously at their natural stride
    ///
    /// ## When to Use
    ///
    /// - **Use `Vector.Inline`** for small vectors (N ≤ ~16) where stack allocation is preferred
    /// - **Use `Vector`** for large vectors where heap allocation avoids stack overflow
    public struct Inline: ~Copyable {
        /// Internal storage using Storage.Inline with optimal layout.
        @usableFromInline
        internal var _storage: Storage<Element>.Inline<N>


        // MARK: - Deinitialization

        deinit {
            // Use non-mutating deinitialize(range:) since Vector.Inline is always
            // fully initialized with N elements in range [0, N).
            let range: Swift.Range<Index_Primitives.Index<Element>> = .zero ..< Index_Primitives.Index<Element>(Ordinal(UInt(N)))
            _storage.deinitialize(range: range)
        }
    }
}

// MARK: - Conditional Conformances

extension Vector.Inline: Sendable where Element: Sendable {}

// MARK: - Equation.Protocol (~Copyable-compatible equality)

extension Vector.Inline: Equation.`Protocol` where Element: Equation.`Protocol` {
    @inlinable
    public static func == (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        for i in 0..<N {
            let slot = Index_Primitives.Index<Element>(Ordinal(UInt(i)))
            if unsafe lhs._storage.pointer(at: slot).pointee != rhs._storage.pointer(at: slot).pointee {
                return false
            }
        }
        return true
    }
}

// MARK: - Hash.Protocol (~Copyable-compatible hashing)

extension Vector.Inline: Hash.`Protocol` where Element: Hash.`Protocol` {
    @inlinable
    public borrowing func hash(into hasher: inout Hasher) {
        for i in 0..<N {
            let slot = Index_Primitives.Index<Element>(Ordinal(UInt(i)))
            unsafe _storage.pointer(at: slot).pointee.hash(into: &hasher)
        }
    }
}

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
        self._storage = Storage<Element>.Inline<N>()
        let ptr: UnsafeMutablePointer<Element> = unsafe _storage.pointer(at: .zero)
        unsafe initializer(ptr)
        _storage.initialization = .linear(count: Index_Primitives.Index<Element>.Count(Cardinal(UInt(N))))
    }


    /// Borrowing iteration.
    @inlinable
    public func forEach<E: Error>(_ body: (borrowing Element) throws(E) -> Void) rethrows {
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
        at index: Vector<Element, N>.Index,
        _ body: (borrowing Element) throws(E) -> R
    ) rethrows -> R {
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

// MARK: - Copyable Only (Element: Copyable)

extension Vector.Inline where Element: Copyable {
    /// Creates a vector from an inline array.
    @inlinable
    public init(_ elements: InlineArray<N, Element>) {
        self._storage = Storage<Element>.Inline<N>()
        for i in 0..<N {
            _storage.initialize(
                to: elements[i],
                at: Index_Primitives.Index<Element>(Ordinal(UInt(i)))
            )
        }
        _storage.initialization = .linear(
            count: Index_Primitives.Index<Element>.Count(Cardinal(UInt(N)))
        )
    }

    /// Creates a vector with all elements set to value.
    @inlinable
    public init(repeating value: Element) {
        self._storage = Storage<Element>.Inline<N>()
        for i in 0..<N {
            let slot = Index_Primitives.Index<Element>(Ordinal(UInt(i)))
            _storage.initialize(to: value, at: slot)
        }
        _storage.initialization = .linear(count: Index_Primitives.Index<Element>.Count(Cardinal(UInt(N))))
    }

    /// The vector elements as an inline array.
    @inlinable
    public var elements: InlineArray<N, Element> {
        get {
            let firstSlot: Index_Primitives.Index<Element> = .zero
            var result = unsafe InlineArray<N, Element>(repeating: _storage.pointer(at: firstSlot).pointee)
            for i in 1..<N {
                let slot = Index_Primitives.Index<Element>(Ordinal(UInt(i)))
                result[i] = unsafe _storage.pointer(at: slot).pointee
            }
            return result
        }
        set {
            for i in 0..<N {
                let slot = Index_Primitives.Index<Element>(Ordinal(UInt(i)))
                unsafe (_storage.pointer(at: slot).pointee = newValue[i])
            }
        }
    }
}
