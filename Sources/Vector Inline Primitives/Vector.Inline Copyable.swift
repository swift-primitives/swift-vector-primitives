// Vector.Inline Copyable.swift
// Extensions for Vector.Inline that require Copyable elements.

// MARK: - Copyable Only (Element: Copyable)

extension Vector.Inline where Element: Copyable {
    /// Creates a vector from an inline array.
    @inlinable
    public init(_ elements: InlineArray<N, Element>) {
        var buffer = Buffer<Element>.Linear.Inline<N>()
        for i in 0..<N {
            _ = buffer.append(elements[i])
        }
        self.init(_buffer: buffer)
    }

    /// Creates a vector with all elements set to value.
    @inlinable
    public init(repeating value: Element) {
        var buffer = Buffer<Element>.Linear.Inline<N>()
        for _ in 0..<N {
            _ = buffer.append(value)
        }
        self.init(_buffer: buffer)
    }

    /// The vector elements as an inline array.
    @inlinable
    public var elements: InlineArray<N, Element> {
        get {
            let firstSlot: Index_Primitives.Index<Element> = .zero
            var result = InlineArray<N, Element>(repeating: _buffer[firstSlot])
            for i in 1..<N {
                let slot = Index_Primitives.Index<Element>(Ordinal(UInt(i)))
                result[i] = _buffer[slot]
            }
            return result
        }
        set {
            for i in 0..<N {
                let slot = Index_Primitives.Index<Element>(Ordinal(UInt(i)))
                _buffer[slot] = newValue[i]
            }
        }
    }
}
