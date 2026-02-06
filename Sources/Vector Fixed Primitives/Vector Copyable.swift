// Vector Copyable.swift
// Extensions for Vector that require Copyable elements.

// MARK: - Mutable Span with CoW

extension Vector where Element: Copyable {
    /// Mutable span with copy-on-write semantics.
    ///
    /// This property ensures unique ownership before providing mutable access.
    /// CoW is handled internally by Buffer.Linear.Bounded.
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

// MARK: - Initialization

extension Vector where Element: Copyable {
    /// Creates a vector by consuming an inline array.
    @inlinable
    public init(_ elements: consuming InlineArray<N, Element>) {
        let capacity = Index_Primitives.Index<Element>.Count(Cardinal(UInt(N)))
        var buffer = Buffer<Element>.Linear.Bounded(minimumCapacity: capacity)
        for i in 0..<N {
            _ = buffer.append(elements[i])
        }
        self.init(_buffer: buffer)
    }
}

extension Vector where Element: Copyable {
    /// Creates a vector with all elements set to value.
    @inlinable
    public init(repeating value: Element) {
        let capacity = Index_Primitives.Index<Element>.Count(Cardinal(UInt(N)))
        var buffer = Buffer<Element>.Linear.Bounded(minimumCapacity: capacity)
        for _ in 0..<N {
            _ = buffer.append(value)
        }
        self.init(_buffer: buffer)
    }
}

// MARK: - Elements Property

extension Vector where Element: Copyable {
    /// The vector elements as an inline array.
    @inlinable
    public var elements: InlineArray<N, Element> {
        get {
            let firstSlot: Index_Primitives.Index<Element> = .zero
            var result = InlineArray<N, Element>(repeating: _buffer[firstSlot])
            for i in 1..<N {
                let slot = Index_Primitives.Index<Element>(Ordinal(UInt(i)))
                result[i] = _buffer[slot]
            }
            return result
        }
        set {
            for i in 0..<N {
                let slot = Index_Primitives.Index<Element>(Ordinal(UInt(i)))
                _buffer[slot] = newValue[i]
            }
        }
    }
}

// MARK: - Typed Subscript (Copyable with CoW)

extension Vector where Element: Copyable {
    /// Accesses the element at the given bounded index with copy-on-write semantics.
    ///
    /// CoW is handled internally by Buffer.Linear.Bounded's Copyable subscript.
    ///
    /// - Parameter index: The bounded index of the element to access.
    @inlinable
    public subscript(index: Index) -> Element {
        _read {
            let slot = Index_Primitives.Index<Element>(index.ordinal)
            yield _buffer[slot]
        }
        _modify {
            let slot = Index_Primitives.Index<Element>(index.ordinal)
            yield &_buffer[slot]
        }
    }
}

// MARK: - Safe Access

extension Vector where Element: Copyable {
    /// Returns the element at the bounded index.
    ///
    /// - Parameter index: The bounded index of the element to access.
    /// - Returns: The element at the index.
    @inlinable
    public func element(at index: Index) -> Element {
        let slot = Index_Primitives.Index<Element>(index.ordinal)
        return _buffer[slot]
    }
}
