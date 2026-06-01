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

// MARK: - UnsafeMutableRawPointer + Index<Tag>

extension UnsafeMutableRawPointer {
    /// Returns a pointer offset by the specified index position.
    @inlinable
    public func advanced<Tag: ~Copyable & ~Escapable>(
        by index: Index<Tag>
    ) -> Self {
        unsafe self.advanced(by: Int(bitPattern: index))
    }
}
