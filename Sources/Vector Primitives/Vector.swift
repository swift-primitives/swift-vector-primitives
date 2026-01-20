// Vector.swift
// Namespace for fixed-size vector types.

/// Namespace for fixed-size vector types.
///
/// `Vector` provides compile-time dimension checking for fixed-size, fully-initialized vectors.
/// The namespace is parameterized by element type.
///
/// ## Usage
///
/// ```swift
/// typealias IntVec3 = Vector<Int>.Inline<3>
/// let v = IntVec3([1, 2, 3])
/// ```
///
/// ## Naming
///
/// This namespace follows [API-NAME-001] by using `Vector.Inline` rather than compound names
/// like `InlineVector`.
public enum Vector<Element: ~Copyable>: ~Copyable {}

extension Vector: Copyable where Element: Copyable {}
extension Vector: Sendable where Element: Sendable {}
