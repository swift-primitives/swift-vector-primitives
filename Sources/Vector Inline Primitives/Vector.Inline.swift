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
        package var _storage: Storage<Element>.Inline<N>

        // MARK: - Internal Initializer

        /// Internal initializer for use by extension modules.
        @usableFromInline
        package init(_storage: consuming Storage<Element>.Inline<N>) {
            self._storage = _storage
        }

        deinit {
            print("Vector.Inline deinit called")
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
