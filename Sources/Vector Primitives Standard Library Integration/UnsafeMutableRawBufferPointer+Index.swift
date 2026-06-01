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

public import Index_Primitives

// MARK: - UnsafeMutableRawBufferPointer + Index<Tag>

extension UnsafeMutableRawBufferPointer {
    /// Creates a mutable buffer pointer from a start address and typed count.
    @inlinable
    public init<Tag: ~Copyable & ~Escapable>(
        start: UnsafeMutableRawPointer?,
        count: Index_Primitives.Index<Tag>.Count
    ) {
        unsafe self.init(start: start, count: Int(bitPattern: count))
    }

    /// Allocates uninitialized memory with typed count and alignment.
    @inlinable
    public static func allocate<Tag: ~Copyable & ~Escapable>(
        count: Index_Primitives.Index<Tag>.Count,
        alignment: Index_Primitives.Index<Tag>.Count
    ) -> Self {
        Self.allocate(byteCount: Int(bitPattern: count), alignment: Int(bitPattern: alignment))
    }

    /// Accesses the byte at the given typed index.
    @inlinable
    public subscript<Tag: ~Copyable & ~Escapable>(
        _ index: Index_Primitives.Index<Tag>
    ) -> UInt8 {
        get { unsafe self[Int(bitPattern: index)] }
        nonmutating set { unsafe self[Int(bitPattern: index)] = newValue }
    }
}
