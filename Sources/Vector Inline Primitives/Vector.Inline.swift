// Vector.Inline.swift
// Fixed-size vector with inline storage (zero heap allocation).

// MARK: - Type Declaration

extension Vector where Element: ~Copyable {
    /// Fixed-size vector with inline storage.
    ///
    /// Uses `Buffer<Element>.Linear.Inline<N>` for zero-allocation stack storage with optimal layout.
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
    /// - **Use `Vector.Inline`** for small vectors (N <= ~16) where stack allocation is preferred
    /// - **Use `Vector`** for large vectors where heap allocation avoids stack overflow
    public struct Inline: ~Copyable {
        /// Internal storage using Buffer.Linear.Inline with optimal layout.
        @usableFromInline
        package var _buffer: Buffer<Element>.Linear.Inline<N>

        // MARK: - Internal Initializer

        /// Internal initializer for use by extension modules.
        @usableFromInline
        package init(_buffer: consuming Buffer<Element>.Linear.Inline<N>) {
            self._buffer = _buffer
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
            if lhs._buffer[slot] != rhs._buffer[slot] {
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
            _buffer[slot].hash(into: &hasher)
        }
    }
}
