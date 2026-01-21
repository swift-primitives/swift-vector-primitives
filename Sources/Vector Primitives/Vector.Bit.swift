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

// MARK: - Heap-Allocated Bit Vector

extension Vector where Element == Bit {
    /// Count of `.one` bits in the vector.
    ///
    /// - Complexity: O(N)
    @inlinable
    public var popcount: Int {
        var count = 0
        for i in 0..<N {
            if unsafe _cachedPtr[i] == .one { count += 1 }
        }
        return count
    }

    /// Sets all bits to `.one`.
    ///
    /// - Complexity: O(N)
    @inlinable
    public mutating func setAll() {
        _makeUnique()
        for i in 0..<N { unsafe (_cachedPtr[i] = .one) }
    }

    /// Clears all bits to `.zero`.
    ///
    /// - Complexity: O(N)
    @inlinable
    public mutating func clearAll() {
        _makeUnique()
        for i in 0..<N { unsafe (_cachedPtr[i] = .zero) }
    }

    /// Toggles (flips) all bits.
    ///
    /// - Complexity: O(N)
    @inlinable
    public mutating func toggleAll() {
        _makeUnique()
        for i in 0..<N { unsafe (_cachedPtr[i] = _cachedPtr[i].flipped) }
    }

    /// Whether all bits are `.zero`.
    @inlinable
    public var isAllZeros: Bool {
        for i in 0..<N {
            if unsafe _cachedPtr[i] == .one { return false }
        }
        return true
    }

    /// Whether all bits are `.one`.
    @inlinable
    public var isAllOnes: Bool {
        for i in 0..<N {
            if unsafe _cachedPtr[i] == .zero { return false }
        }
        return true
    }
}
