// Vector.Inline.swift
// Fixed-size vector with inline storage (zero heap allocation).

// MARK: - Type Declaration

extension Vector where Element: ~Copyable {
    /// Fixed-size vector with inline storage.
    ///
    /// Uses `InlineArray<N, Element>` for zero-allocation stack storage.
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
    /// `Inline` is ~Copyable by default and conditionally Copyable when `Element: Copyable`.
    /// Unlike heap-allocated `Vector`, this type can be conditionally Copyable because
    /// InlineArray handles element lifetime automatically (no manual deinit required).
    ///
    /// ## When to Use
    ///
    /// - **Use `Vector.Inline`** for small vectors (N ≤ ~16) where stack allocation is preferred
    /// - **Use `Vector`** for large vectors where heap allocation avoids stack overflow
    public struct Inline: ~Copyable {
        /// Internal storage.
        @usableFromInline
        internal var _elements: InlineArray<N, Element>
    }
}

// MARK: - Conditional Conformances

extension Vector.Inline: Copyable where Element: Copyable {}
extension Vector.Inline: Sendable where Element: Sendable {}

// MARK: - Equatable (manual implementation - InlineArray doesn't synthesize)

extension Vector.Inline: Equatable where Element: Equatable & Copyable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        for i in 0..<N {
            if lhs._elements[i] != rhs._elements[i] {
                return false
            }
        }
        return true
    }
}

// MARK: - Hashable (manual implementation - InlineArray doesn't synthesize)

extension Vector.Inline: Hashable where Element: Hashable & Copyable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        for i in 0..<N {
            hasher.combine(_elements[i])
        }
    }
}

// MARK: - Unconstrained (Element: ~Copyable)

extension Vector.Inline where Element: ~Copyable {
    /// The fixed dimension.
    @inlinable
    public static var dimension: Int { N }

    /// Creates a vector by consuming an inline array.
    @inlinable
    public init(_ elements: consuming InlineArray<N, Element>) {
        self._elements = elements
    }

    /// Public wrapper for cross-module access.
    ///
    /// Uses `_read`/`_modify` accessors for proper borrowing semantics with ~Copyable elements.
    @inlinable
    public var elements: InlineArray<N, Element> {
        _read { yield _elements }
        _modify { yield &_elements }
    }

    /// Accesses the element at the given index.
    ///
    /// Uses `_read`/`_modify` accessors for proper borrowing semantics with ~Copyable elements.
    ///
    /// - Precondition: `index` must be in `0..<N`.
    @inlinable
    public subscript(index: Int) -> Element {
        _read { yield _elements[index] }
        _modify { yield &_elements[index] }
    }

    /// Borrowing iteration.
    @inlinable
    public func forEach<E: Error>(_ body: (borrowing Element) throws(E) -> Void) rethrows {
        for i in 0..<N {
            try body(_elements[i])
        }
    }

    /// Borrowing access at index.
    ///
    /// - Precondition: `index` must be in `0..<N`.
    @inlinable
    public func withElement<R, E: Error>(
        at index: Int,
        _ body: (borrowing Element) throws(E) -> R
    ) rethrows -> R {
        precondition(index >= 0 && index < N, "Index out of bounds")
        return try body(_elements[index])
    }

    // MARK: - Pointer Access (Internal)

    /// Returns the base pointer for element storage.
    @usableFromInline
    func _basePointer() -> UnsafePointer<Element> {
        unsafe Swift.withUnsafePointer(to: _elements) { storagePtr in
            let basePtr = unsafe UnsafeRawPointer(storagePtr)
            return unsafe basePtr.assumingMemoryBound(to: Element.self)
        }
    }

    /// Returns the mutable base pointer for element storage.
    @usableFromInline
    mutating func _mutableBasePointer() -> UnsafeMutablePointer<Element> {
        unsafe Swift.withUnsafeMutablePointer(to: &_elements) { storagePtr in
            let basePtr = UnsafeMutableRawPointer(storagePtr)
            return unsafe basePtr.assumingMemoryBound(to: Element.self)
        }
    }

    // MARK: - Span Access

    /// Read-only span of all vector elements.
    ///
    /// Provides zero-copy access to the vector's contiguous storage.
    /// Elements are ordered from index 0 to N-1.
    @inlinable
    public var span: Span<Element> {
        _read {
            yield unsafe Span(_unsafeStart: _basePointer(), count: N)
        }
    }

    /// Mutable span of all vector elements.
    ///
    /// Provides zero-copy mutable access to the vector's contiguous storage.
    /// Elements are ordered from index 0 to N-1.
    @inlinable
    public var mutableSpan: MutableSpan<Element> {
        _read {
            let ptr = unsafe UnsafeMutablePointer(mutating: _basePointer())
            yield unsafe MutableSpan(_unsafeStart: ptr, count: N)
        }
        _modify {
            var s = unsafe MutableSpan(_unsafeStart: _mutableBasePointer(), count: N)
            yield &s
        }
    }
}

// MARK: - Copyable Only (Element: Copyable)

extension Vector.Inline where Element: Copyable {
    /// Creates a vector with all elements set to value.
    @inlinable
    public init(repeating value: Element) {
        self._elements = InlineArray(repeating: value)
    }

    /// Total accessor - returns nil for invalid index.
    ///
    /// This method is only available for `Copyable` elements because `Optional`
    /// requires `Copyable` wrapped values.
    @inlinable
    public func element(at index: Int) -> Element? {
        guard index >= 0 && index < N else { return nil }
        return _elements[index]
    }
}
