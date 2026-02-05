// Vector.Inline Copyable.swift
// Extensions for Vector.Inline that require Copyable elements.

// MARK: - Copyable Only (Element: Copyable)

extension Vector.Inline where Element: Copyable {
    /// Creates a vector from an inline array.
    @inlinable
    public init(_ elements: InlineArray<N, Element>) {
        var storage = Storage<Element>.Inline<N>()
        for i in 0..<N {
            storage.initialize(
                to: elements[i],
                at: Index_Primitives.Index<Element>(Ordinal(UInt(i)))
            )
        }
        storage.initialization = .linear(
            count: Index_Primitives.Index<Element>.Count(Cardinal(UInt(N)))
        )
        self.init(_storage: storage)
    }

    /// Creates a vector with all elements set to value.
    @inlinable
    public init(repeating value: Element) {
        var storage = Storage<Element>.Inline<N>()
        for i in 0..<N {
            let slot = Index_Primitives.Index<Element>(Ordinal(UInt(i)))
            storage.initialize(to: value, at: slot)
        }
        storage.initialization = .linear(count: Index_Primitives.Index<Element>.Count(Cardinal(UInt(N))))
        self.init(_storage: storage)
    }

    /// The vector elements as an inline array.
    @inlinable
    public var elements: InlineArray<N, Element> {
        get {
            let firstSlot: Index_Primitives.Index<Element> = .zero
            var result = unsafe InlineArray<N, Element>(repeating: _storage.pointer(at: firstSlot).pointee)
            for i in 1..<N {
                let slot = Index_Primitives.Index<Element>(Ordinal(UInt(i)))
                result[i] = unsafe _storage.pointer(at: slot).pointee
            }
            return result
        }
        set {
            for i in 0..<N {
                let slot = Index_Primitives.Index<Element>(Ordinal(UInt(i)))
                unsafe (_storage.pointer(at: slot).pointee = newValue[i])
            }
        }
    }
}
