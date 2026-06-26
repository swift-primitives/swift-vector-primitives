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

public import Sequence_Primitives
public import Vector_Primitive

// MARK: - Sequenceable (single-pass, consuming attachable; scalar path)
//
// The shared borrowing `makeIterator()` (in `Vector+Iterable.swift`) fulfils
// Sequenceable's consuming requirement (a borrowing witness satisfies a consuming
// requirement), binding the scalar `Iterator` — the same factory that already serves
// `Iterable` and `Swift.Sequence`. This conformance was described in the iteration
// file's comments but never declared; the `Sequence.Protocol` → `Iterable` +
// `Sequenceable` migration left it out, which made the `.satisfies` / `.reduce` /
// `.contains` Sequenceable facades unavailable on `Vector` (the "(test break)" noted
// at commit 8e2d751).
//
// Declared in its own file — split out of `Vector+Iterable.swift` — so the
// Sequenceable witness synthesis lowers to SIL separately from that file's `Iterable`
// `@_implements` synthesis. The combined-file form crashed the Windows 6.3.2 `+Asserts`
// compiler with an `exception 3` SIL-lowering ICE (`ASTLoweringRequest` for
// `Vector+Iterable.swift`); macOS and Linux compile both forms cleanly. If a future
// toolchain fixes the ICE, this file MAY be folded back into `Vector+Iterable.swift`.

extension Vector: Sequenceable where Bound: Copyable {}

extension Vector.Reversed: Sequenceable where Bound: Copyable {}
