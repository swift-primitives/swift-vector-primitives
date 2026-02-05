# Vector Primitives Research

| Document | Topic | Date | Status |
|----------|-------|------|--------|
| noncopyable-conditional-copyable | ~Copyable and conditional Copyable for Vector.Inline | 2026-02-05 | DECISION |

## Summary

### noncopyable-conditional-copyable

Comprehensive investigation of `~Copyable` element support and conditional `Copyable` conformance for `Vector.Inline` and underlying storage primitives.

**Key finding**: Conditional `Copyable` conformance is **architecturally impossible** for inline storage types that support `~Copyable` elements. This is a fundamental Swift language constraint: types with `deinit` cannot conform to `Copyable` (even conditionally).

**Decisions**:
1. Current `@_rawLayout`-based architecture is correct
2. Add closure-based `~Copyable` initializers
3. Do NOT pursue conditional `Copyable` — impossible
