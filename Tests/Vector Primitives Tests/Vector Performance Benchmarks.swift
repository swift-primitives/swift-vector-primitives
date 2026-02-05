// Vector Performance Benchmarks.swift
// Quick performance and allocation analysis

import Testing
import Foundation

@testable import Vector_Primitives
import Vector_Primitives_Test_Support

// MARK: - Timing Utilities

@inline(never)
func measureTime(_ iterations: Int, _ block: () -> Void) -> (total: Double, perIteration: Double) {
    let start = CFAbsoluteTimeGetCurrent()
    for _ in 0..<iterations {
        block()
    }
    let end = CFAbsoluteTimeGetCurrent()
    let total = end - start
    return (total, total / Double(iterations))
}

@inline(never)
func blackHole<T: ~Copyable>(_ value: borrowing T) {
    unsafe withUnsafePointer(to: value) { _ in }
}

// MARK: - Allocation Benchmarks

@Suite("Allocation Benchmarks")
struct AllocationBenchmarks {

    @Test("heap Vector allocation overhead")
    func heapVectorAllocationOverhead() {
        let iterations = 100_000

        let (total, per) = measureTime(iterations) {
            let v = Vector<Int, 3>([1, 2, 3])
            blackHole(v)
        }

        print("═══════════════════════════════════════════")
        print("HEAP Vector<Int, 3> ALLOCATION")
        print("───────────────────────────────────────────")
        print("Iterations: \(iterations)")
        print(unsafe "Total time: \(String(format: "%.4f", total))s")
        print(unsafe "Per iteration: \(String(format: "%.2f", per * 1_000_000_000))ns")
        print("═══════════════════════════════════════════")
    }

    @Test("inline Vector allocation overhead")
    func inlineVectorAllocationOverhead() {
        let iterations = 100_000

        let (total, per) = measureTime(iterations) {
            let v = Vector<Int, 3>.Inline([1, 2, 3])
            blackHole(v)
        }

        print("═══════════════════════════════════════════")
        print("INLINE Vector<Int, 3>.Inline ALLOCATION")
        print("───────────────────────────────────────────")
        print("Iterations: \(iterations)")
        print(unsafe "Total time: \(String(format: "%.4f", total))s")
        print(unsafe "Per iteration: \(String(format: "%.2f", per * 1_000_000_000))ns")
        print("═══════════════════════════════════════════")
    }

    @Test("heap vs inline allocation comparison")
    func heapVsInlineAllocationComparison() {
        let iterations = 50_000

        // Heap
        let (heapTotal, heapPer) = measureTime(iterations) {
            let v = Vector<Int, 3>([1, 2, 3])
            blackHole(v)
        }

        // Inline
        let (inlineTotal, inlinePer) = measureTime(iterations) {
            let v = Vector<Int, 3>.Inline([1, 2, 3])
            blackHole(v)
        }

        let speedup = heapPer / inlinePer

        print("═══════════════════════════════════════════")
        print("ALLOCATION COMPARISON (Vector<Int, 3>)")
        print("───────────────────────────────────────────")
        print(unsafe "Heap total:   \(String(format: "%.4f", heapTotal))s (\(String(format: "%.1f", heapPer * 1_000_000_000))ns/op)")
        print(unsafe "Inline total: \(String(format: "%.4f", inlineTotal))s (\(String(format: "%.1f", inlinePer * 1_000_000_000))ns/op)")
        print(unsafe "Inline speedup: \(String(format: "%.1f", speedup))x faster")
        print("═══════════════════════════════════════════")
    }
}

// MARK: - Access Benchmarks

@Suite("Access Benchmarks")
struct AccessBenchmarks {

    @Test("heap subscript read performance")
    func heapSubscriptReadPerformance() {
        let v = Vector<Int, 3>([10, 20, 30])
        let iterations = 1_000_000

        var sum = 0
        let (total, per) = measureTime(iterations) {
            sum &+= v[0] &+ v[1] &+ v[2]
        }
        blackHole(sum)

        print("═══════════════════════════════════════════")
        print("HEAP SUBSCRIPT READ")
        print("───────────────────────────────────────────")
        print("Iterations: \(iterations)")
        print(unsafe "Total time: \(String(format: "%.4f", total))s")
        print(unsafe "Per iteration: \(String(format: "%.2f", per * 1_000_000_000))ns")
        print("═══════════════════════════════════════════")
    }

    @Test("inline subscript read performance")
    func inlineSubscriptReadPerformance() {
        let v = Vector<Int, 3>.Inline([10, 20, 30])
        let iterations = 1_000_000

        var sum = 0
        let (total, per) = measureTime(iterations) {
            sum &+= v[0] &+ v[1] &+ v[2]
        }
        blackHole(sum)

        print("═══════════════════════════════════════════")
        print("INLINE SUBSCRIPT READ")
        print("───────────────────────────────────────────")
        print("Iterations: \(iterations)")
        print(unsafe "Total time: \(String(format: "%.4f", total))s")
        print(unsafe "Per iteration: \(String(format: "%.2f", per * 1_000_000_000))ns")
        print("═══════════════════════════════════════════")
    }

    @Test("heap vs inline read comparison")
    func heapVsInlineReadComparison() {
        let iterations = 500_000

        let heapV = Vector<Int, 3>([10, 20, 30])
        let inlineV = Vector<Int, 3>.Inline([10, 20, 30])

        var sum1 = 0
        let (heapTotal, heapPer) = measureTime(iterations) {
            sum1 &+= heapV[0] &+ heapV[1] &+ heapV[2]
        }
        blackHole(sum1)

        var sum2 = 0
        let (inlineTotal, inlinePer) = measureTime(iterations) {
            sum2 &+= inlineV[0] &+ inlineV[1] &+ inlineV[2]
        }
        blackHole(sum2)

        let ratio = heapPer / inlinePer

        print("═══════════════════════════════════════════")
        print("READ COMPARISON (Vector<Int, 3>)")
        print("───────────────────────────────────────────")
        print(unsafe "Heap:   \(String(format: "%.4f", heapTotal))s (\(String(format: "%.1f", heapPer * 1_000_000_000))ns/op)")
        print(unsafe "Inline: \(String(format: "%.4f", inlineTotal))s (\(String(format: "%.1f", inlinePer * 1_000_000_000))ns/op)")
        print(unsafe "Ratio: \(String(format: "%.2f", ratio))x")
        print("═══════════════════════════════════════════")
    }
}

// MARK: - Mutation Benchmarks

@Suite("Mutation Benchmarks")
struct MutationBenchmarks {

    @Test("heap mutation with CoW (unique)")
    func heapMutationCoWUnique() {
        var v = Vector<Int, 3>([1, 2, 3])
        let iterations = 100_000

        let (total, per) = measureTime(iterations) {
            v[0] &+= 1
            v[1] &+= 1
            v[2] &+= 1
        }
        blackHole(v)

        print("═══════════════════════════════════════════")
        print("HEAP MUTATION (unique reference - no copy)")
        print("───────────────────────────────────────────")
        print("Iterations: \(iterations)")
        print(unsafe "Total time: \(String(format: "%.4f", total))s")
        print(unsafe "Per iteration: \(String(format: "%.2f", per * 1_000_000_000))ns")
        print("═══════════════════════════════════════════")
    }

    @Test("heap mutation with CoW (shared - triggers copy)")
    func heapMutationCoWShared() {
        let iterations = 10_000

        var totalTime: Double = 0
        for _ in 0..<iterations {
            let original = Vector<Int, 3>([1, 2, 3])
            var copy = original  // Creates shared reference
            blackHole(original)  // Keep original alive

            let start = CFAbsoluteTimeGetCurrent()
            copy[0] = 100  // Triggers CoW copy
            let end = CFAbsoluteTimeGetCurrent()
            totalTime += end - start

            blackHole(copy)
        }

        let per = totalTime / Double(iterations)

        print("═══════════════════════════════════════════")
        print("HEAP MUTATION (shared reference - CoW copy)")
        print("───────────────────────────────────────────")
        print("Iterations: \(iterations)")
        print(unsafe "Total time: \(String(format: "%.4f", totalTime))s")
        print(unsafe "Per mutation (incl copy): \(String(format: "%.1f", per * 1_000_000_000))ns")
        print("═══════════════════════════════════════════")
    }

    @Test("inline mutation (always direct)")
    func inlineMutationDirect() {
        var v = Vector<Int, 3>.Inline([1, 2, 3])
        let iterations = 100_000

        let (total, per) = measureTime(iterations) {
            v[0] &+= 1
            v[1] &+= 1
            v[2] &+= 1
        }
        blackHole(v)

        print("═══════════════════════════════════════════")
        print("INLINE MUTATION (always direct)")
        print("───────────────────────────────────────────")
        print("Iterations: \(iterations)")
        print(unsafe "Total time: \(String(format: "%.4f", total))s")
        print(unsafe "Per iteration: \(String(format: "%.2f", per * 1_000_000_000))ns")
        print("═══════════════════════════════════════════")
    }
}

// MARK: - Copy Benchmarks

@Suite("Copy Benchmarks")
struct CopyBenchmarks {

    @Test("heap copy cost (CoW - shallow)")
    func heapCopyCost() {
        let original = Vector<Int, 3>([1, 2, 3])
        let iterations = 100_000

        let (total, per) = measureTime(iterations) {
            let copy = original
            blackHole(copy)
        }

        print("═══════════════════════════════════════════")
        print("HEAP COPY (CoW shallow - just refcount)")
        print("───────────────────────────────────────────")
        print("Iterations: \(iterations)")
        print(unsafe "Total time: \(String(format: "%.4f", total))s")
        print(unsafe "Per copy: \(String(format: "%.2f", per * 1_000_000_000))ns")
        print("═══════════════════════════════════════════")
    }

//    @Test("inline copy cost (full element copy)")
//    func inlineCopyCost() {
//        let original = Vector<Int, 3>.Inline([1, 2, 3])
//        let iterations = 100_000
//
//        let (total, per) = measureTime(iterations) {
//            let copy = original
//            blackHole(copy)
//        }
//
//        print("═══════════════════════════════════════════")
//        print("INLINE COPY (full element copy)")
//        print("───────────────────────────────────────────")
//        print("Iterations: \(iterations)")
//        print(unsafe "Total time: \(String(format: "%.4f", total))s")
//        print(unsafe "Per copy: \(String(format: "%.2f", per * 1_000_000_000))ns")
//        print("═══════════════════════════════════════════")
//    }
//
//    @Test("heap vs inline copy comparison")
//    func heapVsInlineCopyComparison() {
//        let iterations = 100_000
//
//        let heapOriginal = Vector<Int, 3>([1, 2, 3])
//        let inlineOriginal = Vector<Int, 3>.Inline([1, 2, 3])
//
//        let (heapTotal, heapPer) = measureTime(iterations) {
//            let copy = heapOriginal
//            blackHole(copy)
//        }
//
//        let (inlineTotal, inlinePer) = measureTime(iterations) {
//            let copy = inlineOriginal
//            blackHole(copy)
//        }
//
//        let ratio = inlinePer / heapPer
//
//        print("═══════════════════════════════════════════")
//        print("COPY COMPARISON (Vector<Int, 3>)")
//        print("───────────────────────────────────────────")
//        print(unsafe "Heap (CoW):    \(String(format: "%.4f", heapTotal))s (\(String(format: "%.1f", heapPer * 1_000_000_000))ns/op)")
//        print(unsafe "Inline (full): \(String(format: "%.4f", inlineTotal))s (\(String(format: "%.1f", inlinePer * 1_000_000_000))ns/op)")
//        print(unsafe "Inline/Heap ratio: \(String(format: "%.2f", ratio))x")
//        print("═══════════════════════════════════════════")
//    }
}

// MARK: - Larger Vector Benchmarks

@Suite("Size Scaling Benchmarks")
struct SizeScalingBenchmarks {

    @Test("allocation scaling by dimension")
    func allocationScalingByDimension() {
        let iterations = 10_000

        // Dimension 3
        let (_, heap3Per) = measureTime(iterations) {
            let v = Vector<Int, 3>([1, 2, 3])
            blackHole(v)
        }
        let (_, inline3Per) = measureTime(iterations) {
            let v = Vector<Int, 3>.Inline([1, 2, 3])
            blackHole(v)
        }

        // Dimension 10
        let (_, heap10Per) = measureTime(iterations) {
            let v = Vector<Int, 10>(repeating: 42)
            blackHole(v)
        }
        let (_, inline10Per) = measureTime(iterations) {
            let v = Vector<Int, 10>.Inline(repeating: 42)
            blackHole(v)
        }

        // Dimension 100
        let (_, heap100Per) = measureTime(iterations) {
            let v = Vector<Int, 100>(repeating: 42)
            blackHole(v)
        }
        let (_, inline100Per) = measureTime(iterations) {
            let v = Vector<Int, 100>.Inline(repeating: 42)
            blackHole(v)
        }

        print("═══════════════════════════════════════════")
        print("ALLOCATION SCALING BY DIMENSION")
        print("───────────────────────────────────────────")
        print(unsafe "Dim 3:   Heap \(String(format: "%7.1f", heap3Per * 1_000_000_000))ns | Inline \(String(format: "%7.1f", inline3Per * 1_000_000_000))ns | Ratio \(String(format: "%.1f", heap3Per/inline3Per))x")
        print(unsafe "Dim 10:  Heap \(String(format: "%7.1f", heap10Per * 1_000_000_000))ns | Inline \(String(format: "%7.1f", inline10Per * 1_000_000_000))ns | Ratio \(String(format: "%.1f", heap10Per/inline10Per))x")
        print(unsafe "Dim 100: Heap \(String(format: "%7.1f", heap100Per * 1_000_000_000))ns | Inline \(String(format: "%7.1f", inline100Per * 1_000_000_000))ns | Ratio \(String(format: "%.1f", heap100Per/inline100Per))x")
        print("═══════════════════════════════════════════")
    }

    @Test("copy scaling by dimension")
    func copyScalingByDimension() {
        let iterations = 50_000

        // Prepare vectors
        let heap3 = Vector<Int, 3>(repeating: 42)
        let inline3 = Vector<Int, 3>.Inline(repeating: 42)
        let heap10 = Vector<Int, 10>(repeating: 42)
        let inline10 = Vector<Int, 10>.Inline(repeating: 42)
        let heap100 = Vector<Int, 100>(repeating: 42)
        let inline100 = Vector<Int, 100>.Inline(repeating: 42)

        let (_, heap3Per) = measureTime(iterations) { let c = heap3; blackHole(c) }
        let (_, inline3Per) = measureTime(iterations) { blackHole(inline3) }
        let (_, heap10Per) = measureTime(iterations) { let c = heap10; blackHole(c) }
        let (_, inline10Per) = measureTime(iterations) { blackHole(inline10) }
        let (_, heap100Per) = measureTime(iterations) { let c = heap100; blackHole(c) }
        let (_, inline100Per) = measureTime(iterations) { blackHole(inline100) }

        print("═══════════════════════════════════════════")
        print("COPY SCALING BY DIMENSION")
        print("───────────────────────────────────────────")
        print(unsafe "Dim 3:   Heap \(String(format: "%7.1f", heap3Per * 1_000_000_000))ns | Inline \(String(format: "%7.1f", inline3Per * 1_000_000_000))ns | Ratio \(String(format: "%.1f", inline3Per/heap3Per))x")
        print(unsafe "Dim 10:  Heap \(String(format: "%7.1f", heap10Per * 1_000_000_000))ns | Inline \(String(format: "%7.1f", inline10Per * 1_000_000_000))ns | Ratio \(String(format: "%.1f", inline10Per/heap10Per))x")
        print(unsafe "Dim 100: Heap \(String(format: "%7.1f", heap100Per * 1_000_000_000))ns | Inline \(String(format: "%7.1f", inline100Per * 1_000_000_000))ns | Ratio \(String(format: "%.1f", inline100Per/heap100Per))x")
        print("(Ratio = Inline/Heap, >1 means heap is faster)")
        print("═══════════════════════════════════════════")
    }
}

// MARK: - Span Access Benchmarks

@Suite("Span Benchmarks")
struct SpanBenchmarks {

    @Test("span vs subscript read performance")
    func spanVsSubscriptRead() {
        let v = Vector<Int, 100>(repeating: 42)
        let iterations = 10_000

        // Subscript access
        var sum1 = 0
        let (_, subscriptPer) = measureTime(iterations) {
            for i in try! (0..<100).map(Vector<Int, 100>.Index.init) {
                sum1 &+= v[i]
            }
        }
        blackHole(sum1)

        // Span access
        var sum2 = 0
        let (_, spanPer) = measureTime(iterations) {
            let s = v.span
            for i in s.indices {
                sum2 &+= s[i]
            }
        }
        blackHole(sum2)

        print("═══════════════════════════════════════════")
        print("SPAN vs SUBSCRIPT READ (100 elements)")
        print("───────────────────────────────────────────")
        print(unsafe "Subscript: \(String(format: "%.1f", subscriptPer * 1_000_000_000))ns per full iteration")
        print(unsafe "Span:      \(String(format: "%.1f", spanPer * 1_000_000_000))ns per full iteration")
        print(unsafe "Ratio:     \(String(format: "%.2f", subscriptPer/spanPer))x")
        print("═══════════════════════════════════════════")
    }
}

// MARK: - Memory Layout Analysis

@Suite("Memory Layout")
struct MemoryLayoutBenchmarks {

    @Test("memory layout comparison")
    func memoryLayoutComparison() {
        print("═══════════════════════════════════════════")
        print("MEMORY LAYOUT ANALYSIS")
        print("───────────────────────────────────────────")

        print("\nVector<Int, 3> (Heap):")
        print("  Size:      \(MemoryLayout<Vector<Int, 3>>.size) bytes")
        print("  Stride:    \(MemoryLayout<Vector<Int, 3>>.stride) bytes")
        print("  Alignment: \(MemoryLayout<Vector<Int, 3>>.alignment) bytes")

        print("\nVector<Int, 3>.Inline:")
        print("  Size:      \(MemoryLayout<Vector<Int, 3>.Inline>.size) bytes")
        print("  Stride:    \(MemoryLayout<Vector<Int, 3>.Inline>.stride) bytes")
        print("  Alignment: \(MemoryLayout<Vector<Int, 3>.Inline>.alignment) bytes")

        print("\nVector<Int, 10>.Inline:")
        print("  Size:      \(MemoryLayout<Vector<Int, 10>.Inline>.size) bytes")
        print("  Stride:    \(MemoryLayout<Vector<Int, 10>.Inline>.stride) bytes")
        print("  Alignment: \(MemoryLayout<Vector<Int, 10>.Inline>.alignment) bytes")

        print("\nVector<Int, 100>.Inline:")
        print("  Size:      \(MemoryLayout<Vector<Int, 100>.Inline>.size) bytes")
        print("  Stride:    \(MemoryLayout<Vector<Int, 100>.Inline>.stride) bytes")
        print("  Alignment: \(MemoryLayout<Vector<Int, 100>.Inline>.alignment) bytes")

        print("\nVector<Double, 4>.Inline:")
        print("  Size:      \(MemoryLayout<Vector<Double, 4>.Inline>.size) bytes")
        print("  Stride:    \(MemoryLayout<Vector<Double, 4>.Inline>.stride) bytes")
        print("  Alignment: \(MemoryLayout<Vector<Double, 4>.Inline>.alignment) bytes")

        print("═══════════════════════════════════════════")
    }
}
