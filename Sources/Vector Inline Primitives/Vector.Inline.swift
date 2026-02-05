// Vector.Inline.swift
// Equation.Protocol and Hash.Protocol conformances for inline Vector.

// MARK: - Equation.Protocol (~Copyable-compatible equality)

extension Vector.Inline: Equation.`Protocol` where Element: Equation.`Protocol` {
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

// MARK: - Hash.Protocol (~Copyable-compatible hashing)

extension Vector.Inline: Hash.`Protocol` where Element: Hash.`Protocol` {
    @inlinable
    public borrowing func hash(into hasher: inout Hasher) {
        for i in 0..<N {
            let slot = Index_Primitives.Index<Element>(Ordinal(UInt(i)))
            unsafe _storage.pointer(at: slot).pointee.hash(into: &hasher)
        }
    }
}
