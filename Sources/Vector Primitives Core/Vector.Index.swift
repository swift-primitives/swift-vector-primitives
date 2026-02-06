//
//  File.swift
//  swift-vector-primitives
//
//  Created by Coen ten Thije Boonkkamp on 06/02/2026.
//

// MARK: - Index

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
