# Audit: swift-vector-primitives

## Legacy — Consolidated 2026-04-08

### From: swift-institute/Research/audit-primitives.md (2026-04-03)

**Pre-publication dependency-tree audit — P0/P1/P2 checks**

#### P2: Methods in Type Body [API-IMPL-008]

**File**: `Sources/Vector Primitives Core/Vector.swift` (30 items in body)

The entire file (lines 94-415) is a single struct body with no extensions. Contains stored properties, nested types, computed properties, and methods all in one body.

**Mitigating factor**: The file contains an explicit design note (lines 90-93) stating that nested types are declared inline for `~Copyable` constraint inheritance per [PATTERN-022]. The nested types (`Iterator`, `Reversed`, `ForEach`, `Drain`, `Error`) genuinely require this. However, the computed properties and methods (`isEmpty`, `makeIterator`, `reversed`, `forEach`, `drain`, `_borrowingForEach`, `_consumingDrain`) could be moved to extensions.

**Recommendation**: Move methods to extensions; keep nested types inline per [PATTERN-022].

---

### From: swift-institute/Research/audits/implementation-naming-2026-03-20/swift-core-infrastructure-batch.md (2026-03-20)

**Implementation + naming audit**

HIGH=0, MEDIUM=0, LOW=1, INFO=0
Finding IDs: IMPL-002, PATTERN-017, PATTERN-022, VEC-001
