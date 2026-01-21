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

public import Bit_Primitives

// MARK: - Bit Vector Operations

extension Vector.Inline where Element == Bit {
    /// Count of `.one` bits in the vector.
    ///
    /// - Complexity: O(N)
    @inlinable
    public var popcount: Int {
        var count = 0
        for i in 0..<N {
            if _elements[i] == .one { count += 1 }
        }
        return count
    }

    /// Sets all bits to `.one`.
    ///
    /// - Complexity: O(N)
    @inlinable
    public mutating func setAll() {
        for i in 0..<N { _elements[i] = .one }
    }

    /// Clears all bits to `.zero`.
    ///
    /// - Complexity: O(N)
    @inlinable
    public mutating func clearAll() {
        for i in 0..<N { _elements[i] = .zero }
    }

    /// Toggles (flips) all bits.
    ///
    /// - Complexity: O(N)
    @inlinable
    public mutating func toggleAll() {
        for i in 0..<N { _elements[i] = _elements[i].flipped }
    }

    /// Returns a new vector with all bits flipped.
    ///
    /// - Complexity: O(N)
    @inlinable
    public var flipped: Self {
        var result = self
        result.toggleAll()
        return result
    }

    /// Bitwise AND with another vector.
    ///
    /// - Parameter other: The vector to AND with.
    /// - Returns: A new vector with the result.
    /// - Complexity: O(N)
    @inlinable
    public func and(_ other: Self) -> Self {
        var result = self
        for i in 0..<N {
            result._elements[i] = _elements[i].and(other._elements[i])
        }
        return result
    }

    /// Bitwise OR with another vector.
    ///
    /// - Parameter other: The vector to OR with.
    /// - Returns: A new vector with the result.
    /// - Complexity: O(N)
    @inlinable
    public func or(_ other: Self) -> Self {
        var result = self
        for i in 0..<N {
            result._elements[i] = _elements[i].or(other._elements[i])
        }
        return result
    }

    /// Bitwise XOR with another vector.
    ///
    /// - Parameter other: The vector to XOR with.
    /// - Returns: A new vector with the result.
    /// - Complexity: O(N)
    @inlinable
    public func xor(_ other: Self) -> Self {
        var result = self
        for i in 0..<N {
            result._elements[i] = _elements[i].xor(other._elements[i])
        }
        return result
    }

    /// Whether all bits are `.zero`.
    @inlinable
    public var isAllZeros: Bool {
        for i in 0..<N {
            if _elements[i] == .one { return false }
        }
        return true
    }

    /// Whether all bits are `.one`.
    @inlinable
    public var isAllOnes: Bool {
        for i in 0..<N {
            if _elements[i] == .zero { return false }
        }
        return true
    }
}
