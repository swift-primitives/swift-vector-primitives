# Vector Primitives Experiments

| Directory | Purpose | Date | Toolchain | Status |
|-----------|---------|------|-----------|--------|
| noncopyable-inline-init | Validate ~Copyable initialization patterns for Vector.Inline | 2026-02-05 | Swift 6.2 | CONFIRMED |
| mutablespan-get-only | Investigate mutableSpan[i] = x "get-only property" error | 2026-02-06 | Swift 6.2.3 | SUPERSEDED |
| mutablespan-accessor-strategies | Exhaustive test of accessor patterns for mutableSpan[i] = x | 2026-02-06 | Swift 6.2.3 | CONFIRMED |

## Summary

### noncopyable-inline-init

**Purpose**: Validate initialization patterns for `~Copyable` elements in inline storage.

**Key Findings**:

1. **Closure-based init works** — `init(initializing: (UnsafeMutablePointer<Element>) -> Void)` successfully initializes `~Copyable` elements
2. **Consuming init works** — Multiple `consuming Element` parameters work, but cannot be captured by closures; must use direct pointer access
3. **stdlib pattern works** — `init(unsafeUninitializedCapacity:initializingWith:)` works with modified signature (return count instead of inout)
4. **`@_rawLayout` blocks conditional Copyable** — Types using `@_rawLayout` are always `~Copyable`
5. **deinit + conditional Copyable is incompatible** — Swift constraint: types with deinit cannot conditionally conform to Copyable
6. **`InlineArray` backing crashes** — Using `InlineArray<capacity, Int>` as storage backing for `~Copyable` elements crashes during deinit (memory layout mismatch)

**Critical Conclusion**:
- Storage types supporting `~Copyable` elements MUST have deinit for cleanup
- Types with deinit CANNOT conditionally conform to Copyable
- Therefore: `Vector.Inline` supporting `~Copyable` elements CANNOT be conditionally Copyable
- This is a **fundamental Swift language constraint**, not a bug or design flaw
- The current `@_rawLayout`-based architecture is CORRECT

**Recommendation**:
- Add `~Copyable` initializers to `Vector.Inline` (closure-based or consuming)
- Do NOT attempt conditional Copyable — it is architecturally impossible

### mutablespan-get-only

**Purpose**: Investigate why `v.mutableSpan[0] = x` fails with "cannot assign through subscript: 'mutableSpan' is a get-only property".

**Key Findings**:

1. **Not Vector.Inline-specific** — Even `Array.mutableSpan[0] = x` fails on Swift 6.2.3
2. **Root cause**: `mutating get` returns a value, not an inout reference. Subscript assignment requires read-modify-write on the property, but with only a getter (no setter/_modify), the compiler has no writeback path
3. **Workaround**: Capture `mutableSpan` in a local `var`, then subscript-assign through it
4. **Writes are visible**: MutableSpan writes through its internal `UnsafeMutablePointer`, so changes are visible through the original container without writeback

**Workaround pattern**:
```swift
var span = v.mutableSpan
span[0] = 100
span[1] = 200
// writes visible through v after span goes out of scope
```

**Recommendation**:
- Fix all tests to use the local-var capture pattern
- This is a Swift 6.2.3 compiler limitation, not a design flaw in our types
