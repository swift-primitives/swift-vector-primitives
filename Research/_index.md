# Vector Primitives Research

| Document | Topic | Date | Status |
|----------|-------|------|--------|
| noncopyable-conditional-copyable | ~Copyable and conditional Copyable for stored Vector.Inline (pre-repurpose) | 2026-02-05 | SUPERSEDED |
| vector-dependency-storage-vs-buffer | Should stored Vector depend on Storage or Buffer? (pre-repurpose) | 2026-02-06 | SUPERSEDED |
| audit | Pre-publication dependency-tree audit: 30 items in struct body, mitigated by [PATTERN-022] | 2026-04-08 | LEGACY |

## Note

As of 2026-02-08, swift-vector-primitives has been repurposed for the functional vector `Vector<Bound>` (formerly `Range.Lazy<Bound>` from swift-range-primitives). The stored vector types (`Vector<Element, N>`, `Vector<Element, N>.Inline`) have been removed. See `swift-primitives/Research/vector-rename-analysis.md` v4.0.0 (DECISION) for the full analysis.

The research documents below are preserved for historical reference. They pertain to the stored vector types that no longer exist in this package.

## Summary (Historical)

### noncopyable-conditional-copyable

Comprehensive investigation of `~Copyable` element support and conditional `Copyable` conformance for the stored `Vector.Inline` and underlying storage primitives.

**Key finding**: Conditional `Copyable` conformance is **architecturally impossible** for inline storage types that support `~Copyable` elements. This is a fundamental Swift language constraint: types with `deinit` cannot conform to `Copyable` (even conditionally).

### vector-dependency-storage-vs-buffer

Investigation of whether the stored Vector should depend on `swift-buffer-primitives` or `swift-storage-primitives` directly.

**Key finding (v2)**: Vector IS a linear buffer. Moot after repurposing — the functional `Vector<Bound>` depends on neither storage nor buffer primitives.
