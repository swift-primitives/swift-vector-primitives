// Vector.swift
// Fixed-size vector with compile-time dimension and heap-allocated storage.

/// A fixed-size vector with compile-time dimension and heap-allocated storage.
///
/// `Vector<Element, N>` is the base vector type with copy-on-write heap storage.
/// For stack-allocated storage, use ``Vector/Inline``.
///
/// ## Example
///
/// ```swift
/// var v = Vector<Double, 3>([1.0, 2.0, 3.0])
/// v[0] = 10.0
/// print(v.span)  // Zero-copy access
/// ```
///
/// ## Variants
///
/// - ``Vector``: Heap-allocated with copy-on-write semantics (this type)
/// - ``Vector/Inline``: Zero-allocation inline storage
///
/// ## Move-Only Support
///
/// Both the vector and its elements can be `~Copyable`:
///
/// ```swift
/// struct Resource: ~Copyable { ... }
/// var v = Vector<Resource, 2>([Resource(), Resource()])
/// ```
///
/// ## Copy-on-Write
///
/// When `Element` is `Copyable`, `Vector` uses copy-on-write semantics:
/// copies share storage until mutation, providing efficient value semantics.
@safe
public struct Vector<Element: ~Copyable, let N: Int>: ~Copyable {

    // MARK: - Storage

    /// Internal storage using Storage.Heap for heap storage with CoW.
    @usableFromInline
    internal var _storage: Storage<Element>.Heap
}

// MARK: - Conditional Conformances

extension Vector: Copyable where Element: Copyable {}
extension Vector: @unchecked Sendable where Element: Sendable {}

// MARK: - Equatable

extension Vector: Equatable where Element: Equatable & Copyable {
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

// MARK: - Hashable

extension Vector: Hashable where Element: Hashable & Copyable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        for i in 0..<N {
            let slot = Index_Primitives.Index<Element>(Ordinal(UInt(i)))
            hasher.combine(unsafe _storage.pointer(at: slot).pointee)
        }
    }
}

// MARK: - Unconstrained API (Element: ~Copyable)

extension Vector where Element: ~Copyable {
    /// The fixed dimension.
    @inlinable
    public static var dimension: Int { N }

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
        at index: Index,
        _ body: (borrowing Element) throws(E) -> R
    ) rethrows -> R {
        let slot = Index_Primitives.Index<Element>(index.ordinal)
        return try unsafe body(_storage.pointer(at: slot).pointee)
    }

    // MARK: - Span Access

    /// Read-only span of all vector elements.
    ///
    /// Provides zero-copy access to the vector's contiguous storage.
    public var span: Span<Element> {
        @_lifetime(borrow self)
        @inlinable
        borrowing get {
            let ptr = unsafe UnsafePointer(_storage.pointer(at: .zero))
            let span = unsafe Span(_unsafeStart: ptr, count: N)
            return unsafe _overrideLifetime(span, borrowing: self)
        }
    }

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

// MARK: - Copyable-Only API

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
        self._storage = storage
    }

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
        self._storage = storage
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
            _makeUnique()
            for i in 0..<N {
                let slot = Index_Primitives.Index<Element>(Ordinal(UInt(i)))
                unsafe (_storage.pointer(at: slot).pointee = newValue[i])
            }
        }
    }

    // MARK: - Copy-on-Write

    /// Ensures unique ownership of storage for mutation.
    @usableFromInline
    mutating func _makeUnique() {
        guard !isKnownUniquelyReferenced(&_storage) else { return }
        _storage = _storage.copy()
    }
}
