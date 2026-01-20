// Vector.Inline.swift
// Fixed-size, fully-initialized vector with compile-time dimension.

// MARK: - Type Declaration

extension Vector where Element: ~Copyable {
    /// Fixed-size, fully-initialized vector with compile-time dimension.
    ///
    /// Storage is `InlineArray<N, Element>` directly. Always fully initialized.
    /// No manual deinit needed - InlineArray handles element lifetime.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let v = Vector<Int>.Inline<3>([1, 2, 3])
    /// print(v[0])  // 1
    /// ```
    ///
    /// ## ~Copyable Support
    ///
    /// `Inline` is ~Copyable by default and conditionally Copyable when `Element: Copyable`.
    /// Unlike `Stack.Inline`, this type can be conditionally Copyable because InlineArray
    /// handles element lifetime automatically (no manual deinit required).
    public struct Inline<let N: Int>: ~Copyable {
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
}

// MARK: - Copyable Only (Element: Copyable)

extension Vector.Inline where Element: Copyable {
    /// Creates a vector with all elements set to value.
    @inlinable
    public init(repeating value: Element) {
        self._elements = InlineArray(repeating: value)
    }

    /// Total accessor - returns nil for invalid index per [API-IMPL-003].
    ///
    /// This method is only available for `Copyable` elements because `Optional`
    /// requires `Copyable` wrapped values.
    @inlinable
    public func element(at index: Int) -> Element? {
        guard index >= 0 && index < N else { return nil }
        return _elements[index]
    }
}
