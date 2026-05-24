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

// The lean `Vector Primitive` type module re-exports only the dependencies the
// `Vector` type and its structural surface genuinely need (per [MOD-004] /
// [MOD-036]): `Index_Primitives` (the index domain `Vector` addresses over) and
// `Property_Primitives` (the `.forEach` / `.drain` Property.Inout accessors).
// The Copyable-imposing `Sequence` / `Iterator` conformances and their
// `Sequence_Primitives` import live in the plural `Vector Primitives` ops module.

@_exported public import Index_Primitives
@_exported public import Property_Primitives
