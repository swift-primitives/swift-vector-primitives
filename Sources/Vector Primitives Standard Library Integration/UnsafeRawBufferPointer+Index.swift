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

// MARK: - UnsafeRawBufferPointer + Index<Tag>

extension UnsafeRawBufferPointer {
    /// Creates a buffer pointer from a start address and typed count.
    @inlinable
    public init<Tag: ~Copyable>(
        start: UnsafeRawPointer?,
        count: Index_Primitives.Index<Tag>.Count
    ) {
        unsafe self.init(start: start, count: Int(bitPattern: count))
    }

    /// Accesses the byte at the given typed index.
    @inlinable
    public subscript<Tag: ~Copyable>(
        _ index: Index_Primitives.Index<Tag>
    ) -> UInt8 {
        unsafe self[Int(bitPattern: index)]
    }
}
