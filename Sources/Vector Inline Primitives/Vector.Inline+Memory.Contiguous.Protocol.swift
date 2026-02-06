// Vector.Inline+Memory.Contiguous.Protocol.swift
// Span and mutable span for inline Vector.

import Vector_Primitives_Core
import Memory_Primitives

extension Vector.Inline where Element: ~Copyable {
    // MARK: - Span Access

    /// Read-only span of all vector elements.
    ///
    /// Provides zero-copy access to the vector's contiguous storage.
    /// Elements are ordered from index 0 to N-1.
    public var span: Span<Element> {
        @_lifetime(borrow self)
        @inlinable
        borrowing get {
            _buffer.span
        }
    }
}

extension Vector.Inline where Element: ~Copyable {
    /// Mutable span of all vector elements.
    ///
    /// Provides zero-copy mutable access to the vector's contiguous storage.
    /// Elements are ordered from index 0 to N-1.
    public var mutableSpan: MutableSpan<Element> {
        @_lifetime(&self)
        @inlinable
        mutating get {
            _buffer.mutableSpan
        }
        @_lifetime(&self)
        @inlinable
        _modify {
            yield &_buffer.mutableSpan
        }
    }
}
