# Vector Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Typed half-open integer ranges for Swift — `Vector<Bound>` modeling an index-domain range with typed `Index<Bound>` positions, `Index<Bound>.Offset` displacements, and `Index<Bound>.Count` cardinalities. Companion `Vector.Drop`, `Vector.Prefix`, `Vector.Reversed.{Drop, Prefix}` views compose with the underlying vector to model partial-range slicing without copying, threading typed positions end-to-end so arithmetic mistakes that `Int`-based ranges would silently allow become compile-time errors.

The vector pattern in this package serves the same role as a stdlib `Range<Int>` does for integer iteration, but typed: bounds are `Tagged<Bound, Ordinal>`, counts are `Index<Bound>.Count`, and the views and iteration surface (`Vector.ForEach`, `Vector.Drain`) align with the rest of the data-structures cohort. `Vector` is the index-domain primitive that sits underneath `Cyclic.Group.Static<n>`, sequences over indexed collections, and parser cursor positions.

This package is part of **Story 2 of the data-structures cohort** (`data-structures-launch-2026`): seven packages introducing typed indexing and sequences — order, index, sequence, collection, input, cyclic, **vector**.

---

## Quick Start

```swift
import Vector_Primitives

// A Vector is a scalar generator over a half-open range: each element is produced
// on demand by the transform, so there is no backing buffer to copy.
let squares = try Vector(0..<10) { $0 * $0 }

// Borrowing iteration — the vector survives.
squares.forEach { value in
    print(value)                   // 0, 1, 4, 9, 16, …
}

// Consuming iteration — the vector is drained to empty.
var consumable = try Vector(0..<5) { $0 }
consumable.drain { value in
    print(value)
}

// O(1) prefix / drop views that re-bound the range without recomputing elements.
let head = squares.prefix.first(try .init(3))   // first 3 → 0, 1, 4
let tail = squares.drop.first(try .init(4))      // drops 4 → 16, 25, 36, 49, 64, 81

// Reverse the range, then iterate or slice the reversed view.
let reversed = squares.reversed()
reversed.forEach { value in
    print(value)                   // 81, 64, 49, …
}
```

---

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-vector-primitives.git", branch: "main"),
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Vector Primitives", package: "swift-vector-primitives"),
    ]
)
```

The package is pre-1.0 — until 0.1.0 is tagged, depend on `branch: "main"` rather than `from: "0.1.0"`. Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

Three library products. Foundation-free. No concurrency surface. No platform conditionals.

| Product | When to import | What's in it |
|---------|---------------|--------------|
| `Vector Primitives` | Default for application code | Umbrella re-exporting Core + Standard Library Integration. |
| `Vector Primitives Core` | When you want only the typed-vector surface | `Vector<Bound>`, `Vector.Drop`, `Vector.Prefix`, `Vector.Reversed.{Drop, Prefix}`, `Vector.ForEach`, `Vector.Drain`, and the typed-index integration. |
| `Vector Primitives Standard Library Integration` | Cursors over `Swift.UnsafePointer` / `Swift.UnsafeRawPointer` / `Swift.UnsafeBufferPointer` / `Swift.UnsafeMutableRawPointer` | Stdlib pointer types with `Vector<Index>` integration. |
| `Vector Primitives Test Support` | Test targets | Test fixtures and re-exports for downstream test consumers. |

---

## Platform Support

| Platform | CI | Status |
|----------|-----|--------|
| macOS 26 | Yes | Full support |
| iOS / tvOS / watchOS / visionOS | — | Supported |
| Linux | Yes | Full support |
| Windows | Yes | Full support |

---

## Stability

Pre-1.0. The public API may change while the package remains on `branch: "main"`; consumers should expect breaking changes to surface in commit messages until the first tag. Once tagged, the package follows institute SemVer: post-1.0 breaking changes ship behind a major bump.

---

## Related Packages

Direct dependencies (all already-public):

- [swift-index-primitives](https://github.com/swift-primitives/swift-index-primitives) — `Index<Bound>`, `Index.Offset`, `Index.Count`, the typed-indexing primitives Vector is built on.
- [swift-cyclic-primitives](https://github.com/swift-primitives/swift-cyclic-primitives) — `Cyclic.Group.Static<n>` modular arithmetic; vector and cyclic compose at the index layer.
- [swift-property-primitives](https://github.com/swift-primitives/swift-property-primitives) — `Property<Tag, Base>.Inout`, the phantom-tagged fluent-accessor machinery the iteration surface composes with.
- [swift-range-primitives](https://github.com/swift-primitives/swift-range-primitives) — terminal operations on `Swift.Range<Bound>` used at the iteration boundary.
- [swift-sequence-primitives](https://github.com/swift-primitives/swift-sequence-primitives) — `Sequence.Protocol` and the iterator protocol family the views conform to for stdlib bridging.

Cohort siblings (Story 2 — Typed indexing and sequences) — see [`data-structures-launch-2026`](https://github.com/swift-institute) for the cohort narrative.

---

## Community

<!-- BEGIN: discussion -->
*Discussion thread will be created at first public release.*
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
