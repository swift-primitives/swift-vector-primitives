// Vector Copyable.swift
// Extensions for Vector that require Copyable elements.

// MARK: - Mutable Span with CoW

extension Vector where Element: Copyable {
    /// Mutable span with copy-on-write semantics.
    ///
    /// This property ensures unique ownership before providing mutable access.
    public var mutableSpan: MutableSpan<Element> {
        @_lifetime(&self)
        @inlinable
        mutating get {
            _makeUnique()
            let ptr = unsafe _storage.pointer(at: .zero)
            let span = unsafe MutableSpan(_unsafeStart: ptr, count: N)
            return unsafe _overrideLifetime(span, mutating: &self)
        }
    }
}

// MARK: - Initialization

extension Vector where Element: Copyable {
    /// Creates a vector by consuming an inline array.
    @inlinable
    public init(_ elements: consuming InlineArray<N, Element>) {
        let capacity = Index_Primitives.Index<Element>.Count(Cardinal(UInt(N)))
        let storage = Storage<Element>.Heap.create(minimumCapacity: capacity)
        for i in 0..<N {
            let slot = Index_Primitives.Index<Element>(Ordinal(UInt(i)))
            storage.initialize(to: elements[i], at: slot)
        }
        storage.initialization = .linear(count: capacity)
        self.init(_storage: storage)
    }
}

extension Vector where Element: Copyable {
    /// Creates a vector with all elements set to value.
    @inlinable
    public init(repeating value: Element) {
        let capacity = Index_Primitives.Index<Element>.Count(Cardinal(UInt(N)))
        let storage = Storage<Element>.Heap.create(minimumCapacity: capacity)
        for i in 0..<N {
            let slot = Index_Primitives.Index<Element>(Ordinal(UInt(i)))
            storage.initialize(to: value, at: slot)
        }
        storage.initialization = .linear(count: capacity)
        self.init(_storage: storage)
    }
}

// MARK: - Elements Property

extension Vector where Element: Copyable {
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
            _makeUnique()
            for i in 0..<N {
                let slot = Index_Primitives.Index<Element>(Ordinal(UInt(i)))
                unsafe (_storage.pointer(at: slot).pointee = newValue[i])
            }
        }
    }
}

// MARK: - Copy-on-Write

extension Vector where Element: Copyable {
    /// Ensures unique ownership of storage for mutation.
    @usableFromInline
    mutating func _makeUnique() {
        guard !isKnownUniquelyReferenced(&_storage) else { return }
        _storage = _storage.copy()
    }
}

// MARK: - Typed Subscript (Copyable with CoW)

extension Vector where Element: Copyable {
    /// Accesses the element at the given bounded index with copy-on-write semantics.
    ///
    /// - Parameter index: The bounded index of the element to access.
    @inlinable
    public subscript(index: Index) -> Element {
        _read {
            let slot = Index_Primitives.Index<Element>(index.ordinal)
            yield unsafe _storage.pointer(at: slot).pointee
        }
        _modify {
            _makeUnique()
            let slot = Index_Primitives.Index<Element>(index.ordinal)
            yield unsafe &_storage.pointer(at: slot).pointee
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
        return unsafe _storage.pointer(at: slot).pointee
    }
}
