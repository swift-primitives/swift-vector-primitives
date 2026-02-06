// Vector.swift
// Equatable and Hashable conformances for heap-backed Vector.

// MARK: - Equatable

extension Vector: Equatable where Element: Equatable & Copyable {
    @inlinable
    public static func == (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        for i in 0..<N {
            let slot = Index_Primitives.Index<Element>(Ordinal(UInt(i)))
            if lhs._buffer[slot] != rhs._buffer[slot] {
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
            hasher.combine(_buffer[slot])
        }
    }
}
