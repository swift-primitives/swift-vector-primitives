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

// `Vector Primitives` (plural) is the [MOD-005] umbrella AND the ops module that
// owns the Copyable-imposing `Sequence` / `Iterator` conformances (the files in
// this target). It re-exports the lean `Vector Primitive` type root and the
// Standard Library Integration target so that `import Vector_Primitives` surfaces
// the whole package. Consumers that iterate a `Vector` (use its `Sequence` /
// `Iterator` conformance) MUST import this plural module per SE-0444
// MemberImportVisibility, since the conformances are declared here.

@_exported public import Vector_Primitive
@_exported public import Vector_Primitives_Standard_Library_Integration

// The plural ops module's own source files (Vector+Sequence.Protocol.swift,
// Vector+Sequence.Properties.swift) import `Sequence_Primitives` directly; it is
// re-exported here so the conformances' associated `Sequence` surface is visible
// to consumers through the umbrella.
@_exported public import Sequence_Primitives
