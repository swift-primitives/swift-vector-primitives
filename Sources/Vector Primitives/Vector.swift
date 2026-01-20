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

    // MARK: - Storage (nested to inherit Element's ~Copyable context)

    /// Internal storage class using ManagedBuffer.
    ///
    /// Declared as a nested class inside `Vector` so that the `Element` generic
    /// inherits the `~Copyable` suppression from the outer type.
    @usableFromInline
    final class Storage: ManagedBuffer<Void, Element> {

        /// Creates storage with capacity for N elements.
        @usableFromInline
        static func create() -> Storage {
            let storage = Storage.create(minimumCapacity: N) { _ in () }
            return unsafe unsafeDowncast(storage, to: Storage.self)
        }

        deinit {
            guard N > 0 else { return }
            _ = unsafe withUnsafeMutablePointerToElements { elements in
                for i in 0..<N {
                    unsafe (elements + i).deinitialize(count: 1)
                }
            }
        }

        /// Returns pointer to element storage.
        @usableFromInline
        var _elementsPointer: UnsafeMutablePointer<Element> {
            unsafe withUnsafeMutablePointerToElements { unsafe $0 }
        }

        /// Initializes element at the given index.
        @usableFromInline
        func _initializeElement(at index: Int, to element: consuming Element) {
            let ptr = unsafe withUnsafeMutablePointerToElements { unsafe $0 + index }
            unsafe ptr.initialize(to: element)
        }

        /// Moves element from the given index.
        @usableFromInline
        func _moveElement(at index: Int) -> Element {
            unsafe withUnsafeMutablePointerToElements { elements in
                unsafe (elements + index).move()
            }
        }

        /// Copies all elements to new storage (for CoW).
        @usableFromInline
        func _copyAllElements(to newStorage: Storage) where Element: Copyable {
            _ = unsafe withUnsafeMutablePointerToElements { old in
                unsafe newStorage.withUnsafeMutablePointerToElements { new in
                    unsafe new.initialize(from: old, count: N)
                }
            }
        }
    }

    // MARK: - Properties

    @usableFromInline
    var _storage: Storage

    @usableFromInline
    var _cachedPtr: UnsafeMutablePointer<Element>
}

// MARK: - Conditional Conformances

extension Vector: Copyable where Element: Copyable {}
extension Vector: @unchecked Sendable where Element: Sendable {}

// MARK: - Equatable

extension Vector: Equatable where Element: Equatable & Copyable {
    @inlinable
    public static func == (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        for i in 0..<N {
            if unsafe lhs._cachedPtr[i] != rhs._cachedPtr[i] {
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
            unsafe hasher.combine(_cachedPtr[i])
        }
    }
}

// MARK: - Copy-on-Write

extension Vector where Element: Copyable {
    /// Ensures unique ownership of storage for mutation.
    @usableFromInline
    mutating func _makeUnique() {
        guard !isKnownUniquelyReferenced(&_storage) else { return }
        let newStorage = Storage.create()
        _storage._copyAllElements(to: newStorage)
        _storage = newStorage
        unsafe (_cachedPtr = _storage._elementsPointer)
    }
}

// MARK: - Unconstrained API (Element: ~Copyable)

extension Vector where Element: ~Copyable {
    /// The fixed dimension.
    @inlinable
    public static var dimension: Int { N }

    /// Accesses the element at the given index.
    ///
    /// - Precondition: `index` must be in `0..<N`.
    @inlinable
    public subscript(index: Int) -> Element {
        _read {
            precondition(index >= 0 && index < N, "Index out of bounds")
            yield unsafe _cachedPtr[index]
        }
        _modify {
            precondition(index >= 0 && index < N, "Index out of bounds")
            yield unsafe &_cachedPtr[index]
        }
    }

    /// Borrowing iteration.
    @inlinable
    public func forEach<E: Error>(_ body: (borrowing Element) throws(E) -> Void) rethrows {
        for i in 0..<N {
            try unsafe body(_cachedPtr[i])
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
        return try unsafe body(_cachedPtr[index])
    }

    // MARK: - Span Access

    /// Read-only span of all vector elements.
    ///
    /// Provides zero-copy access to the vector's contiguous storage.
    public var span: Span<Element> {
        @_lifetime(borrow self)
        @inlinable
        borrowing get {
            unsafe Span(_unsafeStart: _cachedPtr, count: N)
        }
    }

    /// Mutable span of all vector elements.
    ///
    /// Provides zero-copy mutable access to the vector's contiguous storage.
    public var mutableSpan: MutableSpan<Element> {
        @_lifetime(&self)
        @inlinable
        mutating get {
            unsafe MutableSpan(_unsafeStart: _cachedPtr, count: N)
        }
    }
}

// MARK: - Copyable-Only API

extension Vector where Element: Copyable {
    /// Accesses the element at the given index with copy-on-write semantics.
    ///
    /// This subscript overrides the unconstrained version to ensure CoW for Copyable elements.
    /// - Precondition: `index` must be in `0..<N`.
    @inlinable
    public subscript(index: Int) -> Element {
        _read {
            precondition(index >= 0 && index < N, "Index out of bounds")
            yield unsafe _cachedPtr[index]
        }
        _modify {
            _makeUnique()
            precondition(index >= 0 && index < N, "Index out of bounds")
            yield unsafe &_cachedPtr[index]
        }
    }

    /// Mutable span with copy-on-write semantics.
    ///
    /// This property overrides the unconstrained version to ensure CoW for Copyable elements.
    public var mutableSpan: MutableSpan<Element> {
        @_lifetime(&self)
        @inlinable
        mutating get {
            _makeUnique()
            return unsafe MutableSpan(_unsafeStart: _cachedPtr, count: N)
        }
    }

    /// Creates a vector by consuming an inline array.
    @inlinable
    public init(_ elements: consuming InlineArray<N, Element>) {
        self._storage = Storage.create()
        unsafe (self._cachedPtr = _storage._elementsPointer)
        for i in 0..<N {
            _storage._initializeElement(at: i, to: elements[i])
        }
    }

    /// Creates a vector with all elements set to value.
    @inlinable
    public init(repeating value: Element) {
        self._storage = Storage.create()
        unsafe (self._cachedPtr = _storage._elementsPointer)
        for i in 0..<N {
            _storage._initializeElement(at: i, to: value)
        }
    }

    /// Total accessor - returns nil for invalid index.
    @inlinable
    public func element(at index: Int) -> Element? {
        guard index >= 0 && index < N else { return nil }
        return unsafe _cachedPtr[index]
    }

    /// The vector elements as an inline array.
    @inlinable
    public var elements: InlineArray<N, Element> {
        get {
            var result = unsafe InlineArray<N, Element>(repeating: _cachedPtr[0])
            for i in 1..<N {
                result[i] = unsafe _cachedPtr[i]
            }
            return result
        }
        set {
            _makeUnique()
            for i in 0..<N {
                unsafe (_cachedPtr[i] = newValue[i])
            }
        }
    }
}
