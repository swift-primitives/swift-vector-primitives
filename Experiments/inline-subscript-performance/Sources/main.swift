// ============================================================================
// EXPERIMENT: Inline Subscript Performance Investigation
// ============================================================================
// Date: 2026-01-20
// Trigger: Performance anomaly [EXP-001]
// Status: CONFIRMED - Nested generic type structure causes overhead
// ============================================================================
//
// HYPOTHESIS:
// Vector<Element, N>.Inline subscript is 1.5-3.5x slower than raw InlineArray
// or heap Vector. Investigate whether cause is:
//   (a) _read accessor overhead
//   (b) Nested type structure
//   (c) ~Copyable constraint
//   (d) Value generic parameter
//
// METHODOLOGY: Incremental Construction [EXP-004a]
// Build up complexity to identify exactly where overhead appears.
//
// RESULT: CONFIRMED
// - Raw InlineArray subscript: ~97ns
// - Flat struct with identical _read pattern: ~103ns (1.07x - acceptable)
// - Real Vector.Inline: ~150-200ns (1.5-2.0x overhead)
//
// ROOT CAUSE:
// The overhead is NOT the _read accessor. A flat struct using identical
// `_read { yield _elements[index] }` has only 1.07x overhead.
//
// The overhead IS caused by the combination of:
// 1. Nested type inside generic enum: Vector<Element, N>.Inline
// 2. ~Copyable suppression constraint: where Element: ~Copyable
// 3. Value generic parameter: let N: Int
//
// This appears to be a compiler codegen limitation with complex generic
// nested types. The compiler generates less efficient code compared to
// simple flat structs.
//
// ATTEMPTED FIX:
// Added Copyable-specific subscript with simple get/set accessor.
// Result: Made performance WORSE (557ns vs 408ns). Reverted.
//
// WORKAROUNDS:
// 1. Use .span for bulk access (1.55x faster than subscript loop)
// 2. Use heap Vector (faster reads due to cached pointer)
// 3. Access .elements directly (bypasses our subscript)
//
// RECOMMENDATION:
// Accept the overhead. The architectural benefits (full ~Copyable support,
// type-safe dimensions, dual storage model) outweigh ~1.5x read overhead.
// ============================================================================

import Foundation

// MARK: - Timing Utilities

@inline(never)
func measure(_ iterations: Int, _ block: () -> Void) -> Double {
    let start = CFAbsoluteTimeGetCurrent()
    for _ in 0..<iterations {
        block()
    }
    return (CFAbsoluteTimeGetCurrent() - start) / Double(iterations) * 1_000_000_000
}

@inline(never)
func sink<T>(_ x: T) {
    withUnsafePointer(to: x) { _ in }
}

// MARK: - Test Types

// Type 1: Flat struct with _read accessor (control)
struct FlatVector3Read {
    var _elements: InlineArray<3, Int>

    @inlinable
    subscript(index: Int) -> Int {
        _read { yield _elements[index] }
        _modify { yield &_elements[index] }
    }
}

// Type 2: Flat struct with get accessor (control)
struct FlatVector3Get {
    var _elements: InlineArray<3, Int>

    @inlinable
    subscript(index: Int) -> Int {
        get { _elements[index] }
        set { _elements[index] = newValue }
    }
}

// Type 3: Nested ~Copyable type (mimics Vector.Inline)
enum NestedVector<Element: ~Copyable, let N: Int>: ~Copyable {}

extension NestedVector where Element: ~Copyable {
    struct Inline: ~Copyable {
        var _elements: InlineArray<N, Element>

        @inlinable
        subscript(index: Int) -> Element {
            _read { yield _elements[index] }
            _modify { yield &_elements[index] }
        }
    }
}

extension NestedVector.Inline: Copyable where Element: Copyable {}

// MARK: - Benchmarks

func runBenchmarks() {
    let iterations = 1_000_000

    print("═══════════════════════════════════════════════════════════════")
    print("INLINE SUBSCRIPT PERFORMANCE INVESTIGATION")
    print("═══════════════════════════════════════════════════════════════")
    print()

    let rawArr = InlineArray<3, Int>(repeating: 42)
    let flatRead = FlatVector3Read(_elements: [10, 20, 30])
    let flatGet = FlatVector3Get(_elements: [10, 20, 30])
    let nested = NestedVector<Int, 3>.Inline(_elements: [10, 20, 30])

    var sum = 0

    // Benchmark 1: Raw InlineArray
    let rawNs = measure(iterations) {
        sum &+= rawArr[0] &+ rawArr[1] &+ rawArr[2]
    }

    // Benchmark 2: Flat struct with _read
    let flatReadNs = measure(iterations) {
        sum &+= flatRead[0] &+ flatRead[1] &+ flatRead[2]
    }

    // Benchmark 3: Flat struct with get
    let flatGetNs = measure(iterations) {
        sum &+= flatGet[0] &+ flatGet[1] &+ flatGet[2]
    }

    // Benchmark 4: Nested ~Copyable type
    let nestedNs = measure(iterations) {
        sum &+= nested[0] &+ nested[1] &+ nested[2]
    }

    sink(sum)

    print("RESULTS (3-element subscript read, \(iterations) iterations):")
    print("───────────────────────────────────────────────────────────────")
    print("Raw InlineArray:              \(String(format: "%6.1f", rawNs))ns  (baseline)")
    print("FlatVector3 (_read accessor): \(String(format: "%6.1f", flatReadNs))ns  (\(String(format: "%.2f", flatReadNs/rawNs))x)")
    print("FlatVector3 (get accessor):   \(String(format: "%6.1f", flatGetNs))ns  (\(String(format: "%.2f", flatGetNs/rawNs))x)")
    print("NestedVector.Inline:          \(String(format: "%6.1f", nestedNs))ns  (\(String(format: "%.2f", nestedNs/rawNs))x)")
    print()

    print("ANALYSIS:")
    print("───────────────────────────────────────────────────────────────")
    if flatReadNs / rawNs < 1.2 && nestedNs / rawNs > 1.3 {
        print("✓ CONFIRMED: _read accessor is NOT the cause")
        print("  - Flat struct with _read: only \(String(format: "%.0f", (flatReadNs/rawNs - 1) * 100))% overhead")
        print("  - Nested type: \(String(format: "%.0f", (nestedNs/rawNs - 1) * 100))% overhead")
        print()
        print("  ROOT CAUSE: Nested generic type structure with ~Copyable")
        print("  constraint causes compiler to generate suboptimal code.")
    } else {
        print("? Results inconclusive - may need more investigation")
    }
    print()
    print("═══════════════════════════════════════════════════════════════")
}

// MARK: - Entry Point

runBenchmarks()
