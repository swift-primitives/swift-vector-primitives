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
public struct Vector<
    Element: ~Copyable,
    let N: Int
>: ~Copyable {

    // MARK: - Storage

    /// Internal storage using Buffer.Linear.Bounded with CoW.
    @usableFromInline
    package var _buffer: Buffer<Element>.Linear.Bounded

    // MARK: - Internal Initializer

    /// Internal initializer for use by extension modules.
    @usableFromInline
    package init(_buffer: consuming Buffer<Element>.Linear.Bounded) {
        self._buffer = _buffer
    }
}

// MARK: - Conditional Conformances


extension Vector: Copyable where Element: Copyable {}
extension Vector: @unchecked Sendable where Element: Sendable {}
