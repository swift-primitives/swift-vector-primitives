// Vector Stress Tests.swift
// Extreme stress tests to break Vector and Vector.Inline

import Testing
import Synchronization
@testable import Vector_Primitives
import Vector_Primitives_Test_Support

// MARK: - Move-Only Element Tracking

final class DeinitTracker: @unchecked Sendable {
    let _count = Atomic<Int>(0)

    var count: Int { _count.load(ordering: .relaxed) }

    func increment() {
        _count.wrappingAdd(1, ordering: .relaxed)
    }

    func reset() {
        _count.store(0, ordering: .relaxed)
    }
}

struct TrackedValue: ~Copyable {
    let value: Int
    let tracker: DeinitTracker

    init(_ value: Int, tracker: DeinitTracker) {
        self.value = value
        self.tracker = tracker
    }

    deinit {
        tracker.increment()
    }
}

// MARK: - Vector Stress Tests

@Suite("Vector Stress")
struct VectorStressTests {

    // MARK: - Dimension Edge Cases

    @Test("single element vector operations")
    func singleElementVectorOperations() {
        var v = Vector<Int, 1>([42])
        #expect(Vector<Int, 1>.dimension == 1)
        #expect(v[0] == 42)
        v[0] = 999
        #expect(v[0] == 999)
        #expect(v.element(at: 0) == 999)
        #expect(v.span.count == 1)
    }

    @Test("large dimension vector (100 elements)")
    func largeDimensionVector() {
        let v = Vector<Int, 100>(repeating: 7)
        #expect(Vector<Int, 100>.dimension == 100)
        for i in try! (0..<100).map(Vector<Int, 100>.Index.init) {
            #expect(v[i] == 7)
        }
        #expect(v.span.count == 100)

        var sum = 0
        v.forEach { sum += $0 }
        #expect(sum == 700)
    }

    @Test("very large dimension vector (1000 elements)")
    func veryLargeDimensionVector() {
        var v = Vector<Int, 1000>(repeating: 0)
        for i in try! (0..<1000).map(Vector<Int, 1000>.Index.init) {
            v[i] = Int(bitPattern: i)
        }

        var sum = 0
        v.forEach { sum += $0 }
        #expect(sum == 499500) // Sum of 0..<1000

        // Verify random access
        #expect(v[0] == 0)
        #expect(v[499] == 499)
        #expect(v[999] == 999)
    }

    // MARK: - Extreme Values

    @Test("Int.max and Int.min values")
    func extremeIntValues() {
        let v = Vector<Int, 3>([Int.min, 0, Int.max])
        #expect(v[0] == Int.min)
        #expect(v[1] == 0)
        #expect(v[2] == Int.max)

        // Test equality with extreme values
        let v2 = Vector<Int, 3>([Int.min, 0, Int.max])
        #expect(v == v2)
    }

    @Test("Double infinity and NaN")
    func extremeDoubleValues() {
        let v = Vector<Double, 5>([
            Double.infinity,
            -Double.infinity,
            Double.nan,
            Double.greatestFiniteMagnitude,
            -Double.greatestFiniteMagnitude
        ])

        #expect(v[0] == Double.infinity)
        #expect(v[1] == -Double.infinity)
        #expect(v[2].isNaN)
        #expect(v[3] == Double.greatestFiniteMagnitude)
        #expect(v[4] == -Double.greatestFiniteMagnitude)
    }

    @Test("zero values everywhere")
    func zeroValuesEverywhere() {
        let v = Vector<Double, 10>(repeating: 0.0)
        var allZero = true
        v.forEach { if $0 != 0.0 { allZero = false } }
        #expect(allZero)

        // Negative zero
        let v2 = Vector<Double, 3>([-0.0, 0.0, -0.0])
        #expect(v2[0] == 0.0) // -0.0 == 0.0 in IEEE 754
    }

    // MARK: - Mutation Stress

    @Test("rapid mutation cycles")
    func rapidMutationCycles() {
        var v = Vector<Int, 10>(repeating: 0)
        let indices = try! (0..<10).map(Vector<Int, 10>.Index.init)

        for cycle in 0..<1000 {
            for i in indices {
                v[i] = cycle * 10 + Int(bitPattern: i)
            }

            // Verify
            for i in indices {
                #expect(v[i] == cycle * 10 + Int(bitPattern: i))
            }
        }
    }

    @Test("alternating subscript and elements mutation")
    func alternatingMutationMethods() {
        var v = Vector<Int, 5>([1, 2, 3, 4, 5])

        for _ in 0..<100 {
            // Mutate via subscript
            v[0] = v[0] + 1
            v[2] = v[2] + 1
            v[4] = v[4] + 1

            // Mutate via elements
            var elements = v.elements
            elements[1] = elements[1] + 1
            elements[3] = elements[3] + 1
            v.elements = elements
        }

        #expect(v[0] == 101)
        #expect(v[1] == 102)
        #expect(v[2] == 103)
        #expect(v[3] == 104)
        #expect(v[4] == 105)
    }

    // MARK: - Copy-on-Write Stress

    @Test("CoW with many copies")
    func cowWithManyCopies() {
        let original = Vector<Int, 5>([1, 2, 3, 4, 5])
        var copies: [Vector<Int, 5>] = []

        // Create many copies
        for _ in 0..<100 {
            copies.append(original)
        }

        // All should be equal to original
        for copy in copies {
            #expect(copy == original)
        }

        // Mutate one copy - shouldn't affect others
        copies[50][0] = 999
        #expect(copies[50][0] == 999)
        #expect(original[0] == 1)

        for (i, copy) in copies.enumerated() where i != 50 {
            #expect(copy[0] == 1)
        }
    }

    @Test("CoW mutation chain")
    func cowMutationChain() {
        var v1 = Vector<Int, 3>([1, 2, 3])
        var v2 = v1
        var v3 = v2
        let v4 = v3

        // Mutate in chain
        v1[0] = 10
        #expect(v1[0] == 10)
        #expect(v2[0] == 1)
        #expect(v3[0] == 1)
        #expect(v4[0] == 1)

        v2[1] = 20
        #expect(v2[1] == 20)
        #expect(v1[1] == 2)
        #expect(v3[1] == 2)
        #expect(v4[1] == 2)

        v3[2] = 30
        #expect(v3[2] == 30)
        #expect(v1[2] == 3)
        #expect(v2[2] == 3)
        #expect(v4[2] == 3)
    }

    // MARK: - Span Stress

    @Test("span iteration with modification between reads")
    func spanIterationWithModification() {
        var v = Vector<Int, 5>([1, 2, 3, 4, 5])

        // Read via span (scoped)
        var sum1 = 0
        do {
            let span1 = v.span
            for i in span1.indices {
                sum1 += span1[i]
            }
        }
        #expect(sum1 == 15)

        // Modify (span1 is now out of scope)
        v[2] = 100

        // Read again - should see modification
        var sum2 = 0
        do {
            let span2 = v.span
            for i in span2.indices {
                sum2 += span2[i]
            }
        }
        #expect(sum2 == 112) // 1+2+100+4+5
    }

    // MARK: - Hash Collision Stress

    @Test("hash consistency under mutation")
    func hashConsistencyUnderMutation() {
        var v = Vector<Int, 3>([1, 2, 3])
        let hash1 = v.hashValue

        // Same values should produce same hash
        let v2 = Vector<Int, 3>([1, 2, 3])
        let hash2 = v2.hashValue
        #expect(hash1 == hash2)

        // Mutation should change hash
        v[0] = 999
        let hash3 = v.hashValue
        // Note: hash collision is possible but unlikely for these values
        #expect(hash1 != hash3 || v[0] == 1) // Either hash changed or value didn't
    }

    // MARK: - Memory Stress

    @Test("large element type")
    func largeElementType() {
        struct LargeStruct: Equatable {
            var a: Int64 = 1
            var b: Int64 = 2
            var c: Int64 = 3
            var d: Int64 = 4
            var e: Int64 = 5
            var f: Int64 = 6
            var g: Int64 = 7
            var h: Int64 = 8
        }

        var v = Vector<LargeStruct, 10>(repeating: LargeStruct())

        for i in try! (0..<10).map(Vector<LargeStruct, 10>.Index.init) {
            let n = Int(bitPattern: i)
            v[i] = LargeStruct(
                a: Int64(n),
                b: Int64(n*2),
                c: Int64(n*3),
                d: Int64(n*4),
                e: Int64(n*5),
                f: Int64(n*6),
                g: Int64(n*7),
                h: Int64(n*8)
            )
        }

        #expect(v[5].a == 5)
        #expect(v[5].h == 40)
    }

    @Test("nested vectors")
    func nestedVectors() {
        // Vector of vectors (inner vectors are Copyable)
        var outer = Vector<Vector<Int, 3>, 3>(repeating: Vector<Int, 3>([0, 0, 0]))

        outer[0] = Vector<Int, 3>([1, 2, 3])
        outer[1] = Vector<Int, 3>([4, 5, 6])
        outer[2] = Vector<Int, 3>([7, 8, 9])

        #expect(outer[0][0] == 1)
        #expect(outer[1][1] == 5)
        #expect(outer[2][2] == 9)
    }
}

// MARK: - Vector.Inline Stress Tests

@Suite("Vector.Inline Stress")
struct VectorInlineStressTests {

    // MARK: - Move-Only Element Tests

    @Test("move-only elements proper cleanup via scope exit")
    func moveOnlyCleanupViaScopeExit() {
        let tracker = DeinitTracker()

        do {
            let v = unsafe Vector<TrackedValue, 3>.Inline(initializing: { ptr in
                unsafe (ptr + 0).initialize(to: TrackedValue(1, tracker: tracker))
                unsafe (ptr + 1).initialize(to: TrackedValue(2, tracker: tracker))
                unsafe (ptr + 2).initialize(to: TrackedValue(3, tracker: tracker))
            })
            #expect(tracker.count == 0)
            _ = v[0].value // Access to prevent unused warning
        }

        // All 3 elements should be deinitialized when v goes out of scope
        #expect(tracker.count == 3)
    }

    @Test("move-only elements with forEach borrowing")
    func moveOnlyForEachBorrowing() {
        let tracker = DeinitTracker()

        let v = unsafe Vector<TrackedValue, 3>.Inline { ptr in
            unsafe (ptr + 0).initialize(to: TrackedValue(10, tracker: tracker))
            unsafe (ptr + 1).initialize(to: TrackedValue(20, tracker: tracker))
            unsafe (ptr + 2).initialize(to: TrackedValue(30, tracker: tracker))
        }

        var sum = 0
        v.forEach { element in
            sum += element.value
        }
        #expect(sum == 60)
        #expect(tracker.count == 0) // Elements should still be alive

        // Let v go out of scope
        _ = v
    }

    @Test("move-only elements with withElement borrowing")
    func moveOnlyWithElementBorrowing() {
        let tracker = DeinitTracker()

        let v = unsafe Vector<TrackedValue, 3>.Inline(initializing: { ptr in
            unsafe (ptr + 0).initialize(to: TrackedValue(100, tracker: tracker))
            unsafe (ptr + 1).initialize(to: TrackedValue(200, tracker: tracker))
            unsafe (ptr + 2).initialize(to: TrackedValue(300, tracker: tracker))
        })

        let idx: Vector<TrackedValue, 3>.Index = 1
        let result = v.withElement(at: idx) { element in
            element.value * 2
        }
        #expect(result == 400)
        #expect(tracker.count == 0) // Elements should still be alive
    }

    // MARK: - Dimension Edge Cases

    @Test("single element inline vector")
    func singleElementInlineVector() {
        var v = Vector<Int, 1>.Inline([42])
        #expect(Vector<Int, 1>.Inline.dimension == 1)
        #expect(v[0] == 42)
        v[0] = 999
        #expect(v[0] == 999)
        #expect(v.span.count == 1)
    }

    @Test("large inline vector (50 elements)")
    func largeInlineVector() {
        var v = Vector<Int, 50>.Inline(repeating: 0)
        for i in 0..<50 {
            v.mutableSpan[i] = i * i
        }

        #expect(v[0] == 0)
        #expect(v[7] == 49)
        #expect(v[49] == 2401)

        var sum = 0
        v.forEach { sum += $0 }
        #expect(sum == 40425) // Sum of squares 0..49
    }

    // MARK: - Mutation Stress

    @Test("rapid inline mutation cycles")
    func rapidInlineMutationCycles() {
        var v = Vector<Int, 10>.Inline(repeating: 0)

        for cycle in 0..<1000 {
            for i in 0..<10 {
                v.mutableSpan[i] = cycle * 10 + i
            }

            for i in v.span.indices {
                #expect(v.span[i] == cycle * 10 + i)
            }
        }
    }

    @Test("mutableSpan stress")
    func mutableSpanStress() {
        var v = Vector<Int, 20>.Inline(repeating: 0)

        // Write via mutableSpan
        for i in 0..<20 {
            v.mutableSpan[i] = i * 3
        }

        // Read via span (scoped)
        var sum = 0
        do {
            let s = v.span
            for i in s.indices {
                sum += s[i]
            }
        }
        #expect(sum == 570) // Sum of 0, 3, 6, ..., 57

        // Modify again (span out of scope)
        for i in 0..<20 {
            let current = v.span[i]
            v.mutableSpan[i] = current + 1
        }

        #expect(v[0] == 1)
        #expect(v[19] == 58)
    }

    // MARK: - Extreme Values

    @Test("inline with extreme double values")
    func inlineExtremeDoubleValues() {
        let v = Vector<Double, 6>.Inline([
            Double.infinity,
            -Double.infinity,
            Double.nan,
            Double.leastNormalMagnitude,
            Double.leastNonzeroMagnitude,
            Double.ulpOfOne
        ])

        #expect(v[0].isInfinite)
        #expect(v[1].isInfinite && v[1] < 0)
        #expect(v[2].isNaN)
        #expect(v[3] == Double.leastNormalMagnitude)
        #expect(v[4] == Double.leastNonzeroMagnitude)
        #expect(v[5] == Double.ulpOfOne)
    }

    // MARK: - Large Element Stress

    @Test("inline with large structs")
    func inlineWithLargeStructs() {
        struct HugeStruct {
            var a: Int64 = 0
            var b: Int64 = 1
            var c: Int64 = 2
            var d: Int64 = 3
            var e: Int64 = 4
            var f: Int64 = 5
            var g: Int64 = 6
            var h: Int64 = 7
            var i: Int64 = 8
            var j: Int64 = 9
            var k: Int64 = 10
            var l: Int64 = 11
            var m: Int64 = 12
            var n: Int64 = 13
            var o: Int64 = 14
            var p: Int64 = 15
        }

        var v = Vector<HugeStruct, 4>.Inline(repeating: HugeStruct())

        #expect(v[0].a == 0)
        #expect(v[0].p == 15)

        v[1].a = 999
        #expect(v[1].a == 999)
        #expect(v[0].a == 0) // Other elements unchanged
    }
}

// MARK: - Concurrent Access Tests (where applicable)

@Suite("Vector Concurrent")
struct VectorConcurrentTests {

    @Test("concurrent reads")
    func concurrentReads() async {
        let v = Vector<Int, 100>(repeating: 42)
        let indices = try! (0..<100).map(Vector<Int, 100>.Index.init)

        await withTaskGroup(of: Int.self) { group in
            for _ in 0..<100 {
                group.addTask {
                    var sum = 0
                    for i in indices {
                        sum += v[i]
                    }
                    return sum
                }
            }

            for await result in group {
                #expect(result == 4200)
            }
        }
    }

    @Test("concurrent copies then independent mutations")
    func concurrentCopiesThenMutations() async {
        let original = Vector<Int, 10>(repeating: 0)
        let indices = try! (0..<10).map(Vector<Int, 10>.Index.init)

        let results = await withTaskGroup(
            of: Vector<Int, 10>.self,
            returning: [Vector<Int, 10>].self
        ) { group in
            for taskId in 0..<10 {
                group.addTask {
                    var copy = original
                    for i in indices {
                        copy[i] = taskId * 10 + Int(bitPattern: i)
                    }
                    return copy
                }
            }

            var collected: [Vector<Int, 10>] = []
            for await result in group {
                collected.append(result)
            }
            return collected
        }

        // Each result should have its own values
        #expect(results.count == 10)

        // Original should be unchanged
        for i in indices {
            #expect(original[i] == 0)
        }
    }
}

// MARK: - Pathological Cases

@Suite("Vector Pathological")
struct VectorPathologicalTests {

    @Test("self-assignment via elements")
    func selfAssignmentViaElements() {
        var v = Vector<Int, 3>([1, 2, 3])
        v.elements = v.elements // Self-assign
        #expect(v[0] == 1)
        #expect(v[1] == 2)
        #expect(v[2] == 3)
    }

    @Test("optional element handling")
    func optionalElementHandling() {
        let v = Vector<Int?, 3>([nil, .some(42), nil])
        #expect(v[0] == nil)
        #expect(v[1] == 42)
        #expect(v[2] == nil)

        // element(at:) with typed Index returns Element (Int?)
        let idx: Vector<Int?, 3>.Index = 1
        let result: Int? = v.element(at: idx)
        #expect(result == .some(42))
    }

    @Test("string elements with unicode")
    func stringElementsWithUnicode() {
        let v = Vector<String, 4>([
            "Hello",
            "世界",
            "🎉🎊🎈",
            "café"
        ])

        #expect(v[0] == "Hello")
        #expect(v[1] == "世界")
        #expect(v[2] == "🎉🎊🎈")
        #expect(v[3] == "café")

        // Verify iteration
        var concatenated = ""
        v.forEach { concatenated += $0 }
        #expect(concatenated == "Hello世界🎉🎊🎈café")
    }

    @Test("empty string elements")
    func emptyStringElements() {
        let v = Vector<String, 3>(repeating: "")
        #expect(v[0].isEmpty)
        #expect(v[1].isEmpty)
        #expect(v[2].isEmpty)
    }

    @Test("reference type elements")
    func referenceTypeElements() {
        class Counter {
            var value: Int
            init(_ value: Int) { self.value = value }
        }

        let c1 = Counter(1)
        let c2 = Counter(2)
        let c3 = Counter(3)

        let v = Vector<Counter, 3>([c1, c2, c3])

        // Modify through reference
        c1.value = 100
        #expect(v[0].value == 100) // Should see the change

        // Modify through vector access
        v[1].value = 200
        #expect(c2.value == 200)
    }

    @Test("closure elements")
    func closureElements() {
        var capturedSum = 0

        let v = Vector<() -> Int, 3>([
            { 1 },
            { 2 },
            { 3 }
        ])

        v.forEach { closure in
            capturedSum += closure()
        }

        #expect(capturedSum == 6)
    }

    @Test("deeply nested optionals")
    func deeplyNestedOptionals() {
        let v = Vector<Int???, 2>([
            .some(.some(.some(42))),
            nil
        ])

        if case .some(.some(.some(let value))) = v[0] {
            #expect(value == 42)
        } else {
            Issue.record("Failed to unwrap deeply nested optional")
        }

        #expect(v[1] == nil)
    }
}

// MARK: - Inline Pathological Cases

@Suite("Vector.Inline Pathological")
struct VectorInlinePathologicalTests {

    @Test("inline self-assignment via elements")
    func inlineSelfAssignmentViaElements() {
        var v = Vector<Int, 3>.Inline([1, 2, 3])
        v.elements = v.elements
        #expect(v[0] == 1)
        #expect(v[1] == 2)
        #expect(v[2] == 3)
    }

//    @Test("inline with reference type elements")
//    func inlineWithReferenceTypeElements() {
//        class Box {
//            var value: Int
//            init(_ v: Int) { value = v }
//        }
//
//        let b1 = Box(10)
//        let b2 = Box(20)
//
//        let v = Vector<Box, 2>.Inline([b1, b2])
//
//        // Modify through reference
//        b1.value = 100
//        #expect(v[0].value == 100)
//
//        // Copy the vector
//        var v2 = v
//
//        // Both point to same boxes
//        b2.value = 200
//        #expect(v[1].value == 200)
//        #expect(v2[1].value == 200)
//
//        // Assign new box to copy
//        v2[0] = Box(999)
//        #expect(v2[0].value == 999)
//        #expect(v[0].value == 100) // Original still has old box reference
//    }

    @Test("inline span bounds")
    func inlineSpanBounds() {
        let v = Vector<Int, 5>.Inline([10, 20, 30, 40, 50])
        let span = v.span

        #expect(span.count == 5)
        #expect(span[0] == 10)
        #expect(span[4] == 50)

        // Indices should be 0..<5
        var collectedIndices: [Int] = []
        for i in span.indices {
            collectedIndices.append(i)
        }
        #expect(collectedIndices == [0, 1, 2, 3, 4])
    }
}
