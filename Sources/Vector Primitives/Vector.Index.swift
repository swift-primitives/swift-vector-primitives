// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension Vector where Element: ~Copyable {
    /// Type-safe bounded index for vector elements.
    ///
    /// Uses `Algebra.Z<N>` to provide compile-time bounds safety,
    /// ensuring indices are always valid for this vector's dimension.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let idx: Vector<Int, 3>.Index = try! Vector<Int, 3>.Index(0)
    /// var v = Vector<Int, 3>.Inline([1, 2, 3])
    /// print(v[idx])  // 1
    /// ```
    public typealias Index = Algebra.Z<N>
}

// MARK: - Typed Subscript (Vector)

extension Vector where Element: ~Copyable {
    /// Accesses the element at the given bounded index.
    ///
    /// - Parameter index: The bounded index of the element to access.
    @inlinable
    public subscript(index: Index) -> Element {
        _read {
            let slot = Index_Primitives.Index<Element>(index.ordinal)
            yield unsafe _storage.pointer(at: slot).pointee
        }
        _modify {
            let slot = Index_Primitives.Index<Element>(index.ordinal)
            yield unsafe &_storage.pointer(at: slot).pointee
        }
    }
}

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

// MARK: - Typed Subscript (Vector.Inline)

extension Vector.Inline where Element: ~Copyable {
    /// Accesses the element at the given bounded index.
    ///
    /// - Parameter index: The bounded index of the element to access.
    @inlinable
    public subscript(index: Vector<Element, N>.Index) -> Element {
        _read {
            let slot = Index_Primitives.Index<Element>(index.ordinal)
            yield unsafe _storage.pointer(at: slot).pointee
        }
        _modify {
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

extension Vector.Inline where Element: Copyable {
    /// Returns the element at the bounded index.
    ///
    /// - Parameter index: The bounded index of the element to access.
    /// - Returns: The element at the index.
    @inlinable
    public func element(at index: Vector<Element, N>.Index) -> Element {
        let slot = Index_Primitives.Index<Element>(index.ordinal)
        return unsafe _storage.pointer(at: slot).pointee
    }
}
