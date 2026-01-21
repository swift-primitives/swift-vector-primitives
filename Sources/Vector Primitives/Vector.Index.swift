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

import Affine_Primitives

extension Vector where Element: ~Copyable {
    /// Type-safe bounded index for vector elements.
    ///
    /// Uses `Affine.Discrete.Bounded<N>` to provide compile-time bounds safety,
    /// ensuring indices are always valid for this vector's dimension.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let idx: Vector<Int, 3>.Index = Vector<Int, 3>.Index(1)!
    /// var v = Vector<Int, 3>.Inline([1, 2, 3])
    /// print(v[idx])  // 2
    /// ```
    public typealias Index = Affine.Discrete.Bounded<N>
}

// MARK: - Typed Subscript (Vector)

extension Vector where Element: ~Copyable {
    /// Accesses the element at the given bounded index.
    ///
    /// - Parameter index: The bounded index of the element to access.
    @inlinable
    public subscript(index: Index) -> Element {
        _read {
            yield unsafe _cachedPtr[index.rawValue]
        }
        _modify {
            yield unsafe &_cachedPtr[index.rawValue]
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
            yield unsafe _cachedPtr[index.rawValue]
        }
        _modify {
            _makeUnique()
            yield unsafe &_cachedPtr[index.rawValue]
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
        _read { yield _elements[index.rawValue] }
        _modify { yield &_elements[index.rawValue] }
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
        unsafe _cachedPtr[index.rawValue]
    }
}

extension Vector.Inline where Element: Copyable {
    /// Returns the element at the bounded index.
    ///
    /// - Parameter index: The bounded index of the element to access.
    /// - Returns: The element at the index.
    @inlinable
    public func element(at index: Vector<Element, N>.Index) -> Element {
        _elements[index.rawValue]
    }
}
