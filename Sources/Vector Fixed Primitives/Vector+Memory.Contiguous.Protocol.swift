// Vector+Memory.Contiguous.Protocol.swift
// Memory.Contiguous.Protocol conformance for heap-backed Vector.

// MARK: - Memory.Contiguous.Protocol Conformance

extension Vector: Memory.Contiguous.`Protocol` {
    // MARK: - Span Access

    /// Read-only span of all vector elements.
    ///
    /// Provides zero-copy access to the vector's contiguous storage.
    public var span: Span<Element> {
        @_lifetime(borrow self)
        @inlinable
        borrowing get {
            self._storage.span
        }
    }
    
    /// Unsafe read access for C interop with unannotated APIs.
    ///
    /// Provides raw pointer access to all `N` elements for C functi    ons
    /// that lack lifetime annotations. For annotated C APIs, prefer ``span``.
    ///
    /// - Parameter body: A closure that receives the buffer pointer.
    /// - Returns: The value returned by `body`.
    /// - Complexity: O(1) plus the complexity of `body`.
    /// - Warning: The buffer pointer is only valid within `body`.
    @inlinable
    public func withUnsafeBufferPointer<R, E: Swift.Error>(
        _ body: (UnsafeBufferPointer<Element>) throws(E) -> R
    ) throws(E) -> R {
        unsafe try self._storage.withUnsafeBufferPointer(body)
    }
}

extension Vector where Element: ~Copyable {
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
