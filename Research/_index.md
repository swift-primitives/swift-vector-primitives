# Vector Primitives Research

| Document | Topic | Date | Status |
|----------|-------|------|--------|
| noncopyable-conditional-copyable | ~Copyable and conditional Copyable for Vector.Inline | 2026-02-05 | DECISION |
| vector-dependency-storage-vs-buffer | Should Vector depend on Storage or Buffer? | 2026-02-06 | IN_PROGRESS |

## Summary

### noncopyable-conditional-copyable

Comprehensive investigation of `~Copyable` element support and conditional `Copyable` conformance for `Vector.Inline` and underlying storage primitives.

**Key finding**: Conditional `Copyable` conformance is **architecturally impossible** for inline storage types that support `~Copyable` elements. This is a fundamental Swift language constraint: types with `deinit` cannot conform to `Copyable` (even conditionally).

**Decisions**:
1. Current `@_rawLayout`-based architecture is correct
2. Add closure-based `~Copyable` initializers
3. Do NOT pursue conditional `Copyable` — impossible

### vector-dependency-storage-vs-buffer

Investigation of whether Vector should depend on `swift-buffer-primitives` or `swift-storage-primitives` directly, and whether Buffer should be enhanced to support Vector's use case.

**Key finding (v2)**: Vector IS a linear buffer — its initialization pattern is `[0, N)`, exactly the linear discipline. The gaps (subscript, span, CoW, Memory.Contiguous.Protocol) are general-purpose capabilities that Buffer.Linear.Bounded should provide. Once Buffer has them, Vector becomes a thin wrapper enforcing `count == capacity == N`.

**Direction**: Enhance Buffer.Linear.Bounded with subscript, span, CoW, and Memory.Contiguous.Protocol conformance. Then migrate Vector to use Buffer.
