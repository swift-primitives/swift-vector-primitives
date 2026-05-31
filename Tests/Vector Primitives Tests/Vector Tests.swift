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

import Testing
import Vector_Primitives_Test_Support

@testable import Vector_Primitives

// MARK: - Test Structure

enum VectorTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
    @Suite struct Performance {}
}

// MARK: - Unit Tests

extension VectorTests.Unit {

    @Test
    func `init creates vector with correct bounds`() throws(VectorTestError) {
        let vector: Vector = try Vector(0..<10) { $0 }
        #expect(vector.count == 10)
        #expect(!vector.isEmpty)
    }

    @Test
    func `count property returns correct value`() throws(VectorTestError) {
        let vector = try Vector(5..<15) { $0 }
        #expect(vector.count == 10)
    }

    @Test
    func `isEmpty returns true for empty vector`() throws(VectorTestError) {
        let vector = try Vector(5..<5) { $0 }
        #expect(vector.isEmpty)
    }

    @Test
    func `isEmpty returns false for non-empty vector`() throws(VectorTestError) {
        let vector = try Vector(0..<1) { $0 }
        #expect(!vector.isEmpty)
    }

    @Test
    func `transform applies correctly`() throws(VectorTestError) {
        let vector = try Vector(0..<5) { $0 * 2 }
        var results: [Int] = []
        vector.forEach { results.append($0) }
        #expect(results == [0, 2, 4, 6, 8])
    }

    @Test
    func `makeIterator produces correct sequence`() throws(VectorTestError) {
        let vector = try Vector(0..<3) { $0 + 10 }
        var iterator: Vector<Int>.Iterator = vector.makeIterator()
        #expect(iterator.next() == 10)
        #expect(iterator.next() == 11)
        #expect(iterator.next() == 12)
        #expect(iterator.next() == nil)
    }

    @Test
    func `reversed produces elements in reverse order`() throws(VectorTestError) {
        let vector = try Vector(0..<5) { $0 }
        let reversed = vector.reversed()
        var results: [Int] = []
        reversed.forEach { results.append($0) }
        #expect(results == [4, 3, 2, 1, 0])
    }

    // MARK: - Sequence.Protocol Conformance Tests

    @Test
    func `satisfies.all returns true when all match`() throws(VectorTestError) {
        var vector = try Vector(0..<10) { $0 }
        #expect(vector.satisfies.all { $0 >= 0 })
    }

    @Test
    func `satisfies.all returns false when one doesn't match`() throws(VectorTestError) {
        var vector = try Vector(0..<10) { $0 }
        #expect(!vector.satisfies.all { $0 > 5 })
    }

    @Test
    func `satisfies.any returns true when one matches`() throws(VectorTestError) {
        var vector = try Vector(0..<10) { $0 }
        #expect(vector.satisfies.any { $0 == 5 })
    }

    @Test
    func `satisfies.any returns false when none match`() throws(VectorTestError) {
        var vector = try Vector(0..<10) { $0 }
        #expect(!vector.satisfies.any { $0 > 100 })
    }

    @Test
    func `satisfies.none returns true when none match`() throws(VectorTestError) {
        var vector = try Vector(0..<10) { $0 }
        #expect(vector.satisfies.none { $0 < 0 })
    }

    @Test
    func `satisfies.none returns false when one matches`() throws(VectorTestError) {
        var vector = try Vector(0..<10) { $0 }
        #expect(!vector.satisfies.none { $0 == 5 })
    }

    @Test
    func `first returns matching element`() throws(VectorTestError) {
        var vector = try Vector(0..<10) { $0 * 2 }
        let result = vector.first { $0 > 10 }
        #expect(result == 12)
    }

    @Test
    func `first returns nil when no match`() throws(VectorTestError) {
        var vector = try Vector(0..<10) { $0 }
        let result = vector.first { $0 > 100 }
        #expect(result == nil)
    }

    @Test
    func `count(where:) returns correct count`() throws(VectorTestError) {
        let vector = try Vector(0..<10) { $0 }
        let evenCount = vector.count(where: { $0 % 2 == 0 })
        #expect(evenCount == 5)
    }

    @Test
    func `reduce.into accumulates correctly`() throws(VectorTestError) {
        var vector = try Vector(1..<6) { $0 }
        let sum = vector.reduce.into(0) { $0 += $1 }
        #expect(sum == 15)
    }

    @Test
    func `reduce.from combines correctly`() throws(VectorTestError) {
        var vector = try Vector(1..<5) { $0 }
        let product = vector.reduce.from(1) { $0 * $1 }
        #expect(product == 24)
    }

    @Test
    func `contains returns true when predicate matches`() throws(VectorTestError) {
        var vector = try Vector(0..<10) { $0 }
        #expect(vector.contains { $0 == 7 })
    }

    @Test
    func `contains returns false when predicate doesn't match`() throws(VectorTestError) {
        var vector = try Vector(0..<10) { $0 }
        #expect(!vector.contains { $0 == 100 })
    }
}

// MARK: - Edge Case Tests

extension VectorTests.EdgeCase {

    @Test
    func `empty vector forEach does nothing`() throws(VectorTestError) {
        let vector = try Vector(0..<0) { $0 }
        var count = 0
        vector.forEach { _ in count += 1 }
        #expect(count == 0)
    }

    @Test
    func `empty vector satisfies.all returns true`() throws(VectorTestError) {
        var vector = try Vector(0..<0) { $0 }
        #expect(vector.satisfies.all { _ in false })
    }

    @Test
    func `empty vector satisfies.any returns false`() throws(VectorTestError) {
        var vector = try Vector(0..<0) { $0 }
        #expect(!vector.satisfies.any { _ in true })
    }

    @Test
    func `empty vector first returns nil`() throws(VectorTestError) {
        var vector = try Vector(0..<0) { $0 }
        #expect(vector.first { _ in true } == nil)
    }

    @Test
    func `empty vector count(where:) returns zero`() throws(VectorTestError) {
        let vector = try Vector(0..<0) { $0 }
        #expect(vector.count(where: { _ in true }) == 0)
    }

    @Test
    func `single element vector works correctly`() throws(VectorTestError) {
        var vector = try Vector(0..<1) { $0 * 10 }
        #expect(vector.count == 1)
        #expect(vector.first { _ in true } == 0)

        var results: [Int] = []
        vector.forEach { results.append($0) }
        #expect(results == [0])
    }

    @Test
    func `large vector count is efficient (O(1))`() throws(VectorTestError) {
        let vector = try Vector(0..<1_000_000) { $0 }
        #expect(vector.count == 1_000_000)
    }

    @Test
    func `negative transform values work`() throws(VectorTestError) {
        let vector = try Vector(0..<5) { -$0 }
        var results: [Int] = []
        vector.forEach { results.append($0) }
        #expect(results == [0, -1, -2, -3, -4])
    }
}

// MARK: - Reversed Tests

enum VectorReversedTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
}

extension VectorReversedTests.Unit {

    @Test
    func `reversed count matches original`() throws(VectorTestError) {
        let vector = try Vector(0..<10) { $0 }
        let reversed = vector.reversed()
        #expect(reversed.count == 10)
    }

    @Test
    func `reversed isEmpty matches original`() throws(VectorTestError) {
        let vector = try Vector(5..<5) { $0 }
        let reversed = vector.reversed()
        #expect(reversed.isEmpty)
    }

    @Test
    func `reversed iterator produces correct order`() throws(VectorTestError) {
        let vector = try Vector(0..<3) { $0 }
        let reversed = vector.reversed()
        var iterator: Vector<Int>.Reversed.Iterator = reversed.makeIterator()
        #expect(iterator.next() == 2)
        #expect(iterator.next() == 1)
        #expect(iterator.next() == 0)
        #expect(iterator.next() == nil)
    }

    @Test
    func `reversed satisfies.all works correctly`() throws(VectorTestError) {
        let vector = try Vector(0..<10) { $0 }
        var reversed = vector.reversed()
        #expect(reversed.satisfies.all { $0 >= 0 && $0 < 10 })
    }

    @Test
    func `reversed first finds from end`() throws(VectorTestError) {
        let vector = try Vector(0..<10) { $0 }
        var reversed = vector.reversed()
        let result = reversed.first { $0 < 5 }
        #expect(result == 4)
    }

    @Test
    func `reversed count(where:) works correctly`() throws(VectorTestError) {
        let vector = try Vector(0..<10) { $0 }
        let reversed = vector.reversed()
        #expect(reversed.count(where: { $0 % 2 == 0 }) == 5)
    }

    @Test
    func `reversed reduce.into accumulates in reverse order`() throws(VectorTestError) {
        let vector = try Vector(1..<4) { $0 }
        var reversed = vector.reversed()
        var order: [Int] = []
        _ = reversed.reduce.into(0) { acc, val in
            order.append(val)
            acc += val
        }
        #expect(order == [3, 2, 1])
    }
}

extension VectorReversedTests.EdgeCase {

    @Test
    func `empty reversed vector works`() throws(VectorTestError) {
        let vector = try Vector(0..<0) { $0 }
        var reversed = vector.reversed()
        #expect(reversed.isEmpty)
        #expect(reversed.first { _ in true } == nil)
    }

    @Test
    func `single element reversed works`() throws(VectorTestError) {
        let vector = try Vector(0..<1) { $0 * 5 }
        let reversed = vector.reversed()
        #expect(reversed.count == 1)
        var results: [Int] = []
        reversed.forEach { results.append($0) }
        #expect(results == [0])
    }
}

// MARK: - Invariant Tests (Brutal)

enum VectorInvariantTests {
    @Suite struct Iterator {}
    @Suite struct Consistency {}
    @Suite struct Drain {}
    @Suite struct Symmetry {}
    @Suite struct Boundaries {}
}

// MARK: - Iterator Invariants

extension VectorInvariantTests.Iterator {

    @Test
    func `INVARIANT: Iterator returns nil forever after exhaustion`() throws(VectorTestError) {
        let vector = try Vector(0..<3) { $0 }
        var iterator: Vector<Int>.Iterator = vector.makeIterator()

        // Exhaust the iterator
        _ = iterator.next()
        _ = iterator.next()
        _ = iterator.next()

        // Must return nil forever
        for _ in 0..<100 {
            #expect(iterator.next() == nil)
        }
    }

    @Test
    func `INVARIANT: Reversed iterator returns nil forever after exhaustion`() throws(VectorTestError) {
        let vector = try Vector(0..<3) { $0 }
        var iterator: Vector<Int>.Reversed.Iterator = vector.reversed().makeIterator()

        // Exhaust
        _ = iterator.next()
        _ = iterator.next()
        _ = iterator.next()

        // Must return nil forever
        for _ in 0..<100 {
            #expect(iterator.next() == nil)
        }
    }

    @Test
    func `INVARIANT: Empty iterator returns nil immediately and forever`() throws(VectorTestError) {
        let vector = try Vector(0..<0) { $0 }
        var iterator: Vector<Int>.Iterator = vector.makeIterator()

        for _ in 0..<100 {
            #expect(iterator.next() == nil)
        }
    }

    @Test
    func `INVARIANT: Iterator count matches vector.count exactly`() throws(VectorTestError) {
        for size in [0, 1, 2, 10, 100, 1000] {
            let vector = try Vector(0..<size) { $0 }
            var iterator: Vector<Int>.Iterator = vector.makeIterator()
            var iteratedCount: Vector<Int>.Index.Count = 0

            while iterator.next() != nil {
                iteratedCount += 1
            }

            #expect(
                iteratedCount == vector.count,
                "Size \(size): iterated \(iteratedCount) but count is \(vector.count)"
            )
        }
    }

    @Test
    func `INVARIANT: Reversed iterator count matches vector.count exactly`() throws(VectorTestError) {
        for size in [0, 1, 2, 10, 100, 1000] {
            let vector = try Vector(0..<size) { $0 }
            var iterator: Vector<Int>.Reversed.Iterator = vector.reversed().makeIterator()
            var iteratedCount: Vector<Int>.Index.Count = 0

            while iterator.next() != nil {
                iteratedCount += 1
            }

            #expect(
                iteratedCount == vector.count,
                "Size \(size): reversed iterated \(iteratedCount) but count is \(vector.count)"
            )
        }
    }
}

// MARK: - Consistency Invariants

extension VectorInvariantTests.Consistency {

    @Test
    func `INVARIANT: contains(predicate) == (first(predicate) != nil)`() throws(VectorTestError) {
        for size in [0, 1, 5, 20] {
            var vector1 = try Vector(0..<size) { $0 }
            var vector2 = try Vector(0..<size) { $0 }

            // Test with predicate that matches
            let containsEven = vector1.contains { $0 % 2 == 0 }
            let firstEven = vector2.first { $0 % 2 == 0 }
            #expect(
                containsEven == (firstEven != nil),
                "Size \(size): contains(even) = \(containsEven), first != nil = \(firstEven != nil)"
            )

            // Test with predicate that never matches
            var vector3 = try Vector(0..<size) { $0 }
            var vector4 = try Vector(0..<size) { $0 }
            let containsNegative = vector3.contains { $0 < 0 }
            let firstNegative = vector4.first { $0 < 0 }
            #expect(containsNegative == (firstNegative != nil))
        }
    }

    @Test
    func `INVARIANT: satisfies.any(p) == !satisfies.none(p)`() throws(VectorTestError) {
        for size in [0, 1, 5, 20] {
            // Predicate that matches some elements
            var vector1 = try Vector(0..<size) { $0 }
            var vector2 = try Vector(0..<size) { $0 }
            let anyEven = vector1.satisfies.any { $0 % 2 == 0 }
            let noneEven = vector2.satisfies.none { $0 % 2 == 0 }
            #expect(
                anyEven == !noneEven,
                "Size \(size): any(even) = \(anyEven), none(even) = \(noneEven)"
            )

            // Predicate that matches no elements
            var vector3 = try Vector(0..<size) { $0 }
            var vector4 = try Vector(0..<size) { $0 }
            let anyNegative = vector3.satisfies.any { $0 < 0 }
            let noneNegative = vector4.satisfies.none { $0 < 0 }
            #expect(anyNegative == !noneNegative)
        }
    }

    @Test
    func `INVARIANT: satisfies.all(p) implies satisfies.any(p) for non-empty`() throws(VectorTestError) {
        for size in [1, 5, 20] {
            var vector1 = try Vector(0..<size) { $0 }
            var vector2 = try Vector(0..<size) { $0 }

            let allNonNegative = vector1.satisfies.all { $0 >= 0 }
            let anyNonNegative = vector2.satisfies.any { $0 >= 0 }

            if allNonNegative {
                #expect(
                    anyNonNegative,
                    "Size \(size): all(>=0) is true but any(>=0) is false"
                )
            }
        }
    }

    @Test
    func `INVARIANT: count(where: { true }) == count property`() throws(VectorTestError) {
        for size in [0, 1, 5, 100] {
            let vector = try Vector(0..<size) { $0 }
            let countWhere = vector.count(where: { _ in true })
            #expect(
                countWhere == vector.count,
                "Size \(size): count(where: true) = \(countWhere)"
            )
        }
    }

    @Test
    func `INVARIANT: count(where: { false }) == 0`() throws(VectorTestError) {
        for size in [0, 1, 5, 100] {
            let vector = try Vector(0..<size) { $0 }
            let countWhere = vector.count(where: { _ in false })
            #expect(
                countWhere == 0,
                "Size \(size): count(where: false) = \(countWhere)"
            )
        }
    }

    @Test
    func `INVARIANT: reduce.into(initial) { } returns initial for empty vector`() throws(VectorTestError) {
        var vector = try Vector(0..<0) { $0 }
        let result = vector.reduce.into(42) { acc, _ in acc += 1 }
        #expect(result == 42)
    }

    @Test
    func `INVARIANT: reduce.from(initial) { } returns initial for empty vector`() throws(VectorTestError) {
        var vector = try Vector(0..<0) { $0 }
        let result = vector.reduce.from(42) { _, _ in 0 }
        #expect(result == 42)
    }

    @Test
    func `INVARIANT: Transform is deterministic - same index gives same value`() throws(VectorTestError) {
        let vector = try Vector(0..<5) { i in
            i * 7 + 3
        }

        // Iterate multiple times and verify same values
        var results1: [Int] = []
        var results2: [Int] = []

        var iter1: Vector<Int>.Iterator = vector.makeIterator()
        while let v = iter1.next() { results1.append(v) }

        var iter2: Vector<Int>.Iterator = vector.makeIterator()
        while let v = iter2.next() { results2.append(v) }

        #expect(results1 == results2)
        #expect(results1 == [3, 10, 17, 24, 31])
    }
}

// MARK: - Drain Invariants

extension VectorInvariantTests.Drain {

    @Test
    func `INVARIANT: drain empties the vector completely`() throws(VectorTestError) {
        var vector = try Vector(0..<10) { $0 }
        var drained: [Int] = []

        vector.drain { drained.append($0) }

        #expect(drained.count == 10)
        #expect(vector.isEmpty)
    }

    @Test
    func `INVARIANT: drain on empty vector does nothing`() throws(VectorTestError) {
        var vector = try Vector(0..<0) { $0 }
        var drainCount = 0

        vector.drain { _ in drainCount += 1 }

        #expect(drainCount == 0)
        #expect(vector.isEmpty)
    }

    @Test
    func `INVARIANT: double drain yields nothing second time`() throws(VectorTestError) {
        var vector = try Vector(0..<5) { $0 }
        var first: [Int] = []
        var second: [Int] = []

        vector.drain { first.append($0) }
        vector.drain { second.append($0) }

        #expect(first == [0, 1, 2, 3, 4])
        #expect(second == [])
    }

    @Test
    func `INVARIANT: reversed drain empties the vector completely`() throws(VectorTestError) {
        let vector = try Vector(0..<10) { $0 }
        var reversed = vector.reversed()
        var drained: [Int] = []

        reversed.drain { drained.append($0) }

        #expect(drained == [9, 8, 7, 6, 5, 4, 3, 2, 1, 0])
        #expect(reversed.isEmpty)
    }
}

// MARK: - Symmetry Invariants

extension VectorInvariantTests.Symmetry {

    @Test
    func `INVARIANT: Forward + Reversed cover all elements exactly once`() throws(VectorTestError) {
        for size in [0, 1, 5, 20] {
            var forward: [Int] = []
            var backward: [Int] = []

            let vector1 = try Vector(0..<size) { $0 }
            vector1.forEach { forward.append($0) }

            let vector2 = try Vector(0..<size) { $0 }
            let reversed = vector2.reversed()
            reversed.forEach { backward.append($0) }

            #expect(forward.count == size)
            #expect(backward.count == size)
            #expect(
                Set(forward) == Set(backward),
                "Forward and reversed should cover same elements"
            )
            #expect(
                forward == backward.reversed(),
                "Reversed should be exact reverse of forward"
            )
        }
    }

    @Test
    func `INVARIANT: reduce forward and reversed give same sum`() throws(VectorTestError) {
        for size in [0, 1, 5, 20] {
            var vector1 = try Vector(0..<size) { $0 }
            let vector2 = try Vector(0..<size) { $0 }

            let forwardSum = vector1.reduce.into(0) { $0 += $1 }
            var reversed = vector2.reversed()
            let backwardSum = reversed.reduce.into(0) { $0 += $1 }

            #expect(
                forwardSum == backwardSum,
                "Size \(size): forward sum \(forwardSum) != backward sum \(backwardSum)"
            )
        }
    }

    @Test
    func `INVARIANT: count(where:) same for forward and reversed`() throws(VectorTestError) {
        for size in [0, 1, 5, 20] {
            let vector1 = try Vector(0..<size) { $0 }
            let vector2 = try Vector(0..<size) { $0 }

            let forwardCount = vector1.count(where: { $0 % 2 == 0 })
            let backwardCount = vector2.reversed().count(where: { $0 % 2 == 0 })

            #expect(forwardCount == backwardCount)
        }
    }

    @Test
    func `INVARIANT: satisfies.all same for forward and reversed`() throws(VectorTestError) {
        for size in [0, 1, 5, 20] {
            var vector1 = try Vector(0..<size) { $0 }
            let vector2 = try Vector(0..<size) { $0 }

            let forwardAll = vector1.satisfies.all { $0 >= 0 }
            var reversed = vector2.reversed()
            let backwardAll = reversed.satisfies.all { $0 >= 0 }

            #expect(forwardAll == backwardAll)
        }
    }
}

// MARK: - Boundary Invariants

extension VectorInvariantTests.Boundaries {

    @Test
    func `INVARIANT: Offset vectors work correctly`() throws(VectorTestError) {
        let vector = try Vector(100..<105) { $0 }
        var results: [Int] = []
        var iter: Vector<Int>.Iterator = vector.makeIterator()
        while let v = iter.next() { results.append(v) }

        #expect(results == [100, 101, 102, 103, 104])
        #expect(vector.count == 5)
    }

    @Test
    func `INVARIANT: Large offset vectors work correctly`() throws(VectorTestError) {
        let start = 1_000_000
        let vector = try Vector(start..<(start + 5)) { $0 }

        #expect(vector.count == 5)

        var iter: Vector<Int>.Iterator = vector.makeIterator()
        #expect(iter.next() == 1_000_000)
        #expect(iter.next() == 1_000_001)
    }

    @Test
    func `INVARIANT: Transform with overflow-safe arithmetic`() throws(VectorTestError) {
        // Use transforms that don't overflow
        let vector = try Vector(0..<5) { Int.max - 10 + $0 }
        var results: [Int] = []
        var iter: Vector<Int>.Iterator = vector.makeIterator()
        while let v = iter.next() { results.append(v) }

        #expect(results.count == 5)
        #expect(results[0] == Int.max - 10)
        #expect(results[4] == Int.max - 6)
    }

    @Test
    func `INVARIANT: Negative start vectors work`() throws(VectorTestError) {
        let vector = try Vector(-5..<5) { $0 }
        #expect(vector.count == 10)

        var results: [Int] = []
        var iter: Vector<Int>.Iterator = vector.makeIterator()
        while let v = iter.next() { results.append(v) }

        #expect(results == [-5, -4, -3, -2, -1, 0, 1, 2, 3, 4])
    }

    @Test
    func `INVARIANT: Complex transform maintains invariants`() throws(VectorTestError) {
        // Transform: triangular numbers
        let vector = try Vector(1..<6) { n in n * (n + 1) / 2 }

        var results: [Int] = []
        var iter: Vector<Int>.Iterator = vector.makeIterator()
        while let v = iter.next() { results.append(v) }

        #expect(results == [1, 3, 6, 10, 15])
        #expect(vector.count == 5)
    }

    @Test
    func `INVARIANT: first returns first matching, not any matching`() throws(VectorTestError) {
        var vector = try Vector(0..<100) { $0 }
        let result = vector.first { $0 > 50 }
        #expect(result == 51, "first should return 51, not any value > 50")
    }

    @Test
    func `INVARIANT: reversed first returns last matching from original`() throws(VectorTestError) {
        let vector = try Vector(0..<100) { $0 }
        var reversed = vector.reversed()
        let result = reversed.first { $0 < 50 }
        #expect(result == 49, "reversed first should return 49 (last element < 50)")
    }
}

// MARK: - Stress Tests

enum VectorStressTests {
    @Suite struct Stress {}
}

extension VectorStressTests.Stress {

    @Test
    func `STRESS: Many small vectors maintain invariants`() throws(VectorTestError) {
        for i in 0..<100 {
            let vector = try Vector(i..<(i + 10)) { $0 * 2 }
            #expect(vector.count == 10)

            var sum = 0
            var iter: Vector<Int>.Iterator = vector.makeIterator()
            while let v = iter.next() { sum += v }

            let expected = (i..<(i + 10)).map { $0 * 2 }.reduce(0, +)
            #expect(sum == expected, "Vector starting at \(i): sum \(sum) != expected \(expected)")
        }
    }

    @Test
    func `STRESS: Alternating forward/reversed operations`() throws(VectorTestError) {
        for size in [1, 5, 10, 50] {
            var forwardSum = 0
            var reversedSum = 0

            for i in 0..<10 {
                if i % 2 == 0 {
                    var vector = try Vector(0..<size) { $0 }
                    forwardSum += vector.reduce.into(0) { $0 += $1 }
                } else {
                    let vector = try Vector(0..<size) { $0 }
                    var reversed = vector.reversed()
                    reversedSum += reversed.reduce.into(0) { $0 += $1 }
                }
            }

            #expect(
                forwardSum == reversedSum,
                "Size \(size): forward \(forwardSum) != reversed \(reversedSum)"
            )
        }
    }

    @Test
    func `STRESS: Predicate operations on various sizes`() throws(VectorTestError) {
        for size in [0, 1, 2, 10, 100, 500] {
            let vector1 = try Vector(0..<size) { $0 }
            var vector2 = try Vector(0..<size) { $0 }
            var vector3 = try Vector(0..<size) { $0 }

            // These should all be consistent
            let countEven = vector1.count(where: { $0 % 2 == 0 })
            let anyEven = vector2.satisfies.any { $0 % 2 == 0 }
            let allEven = vector3.satisfies.all { $0 % 2 == 0 }

            // Verify relationships
            if size == 0 {
                #expect(countEven == 0)
                #expect(!anyEven)
                #expect(allEven)  // vacuously true
            } else if size == 1 {
                #expect(countEven == 1)  // 0 is even
                #expect(anyEven)
                #expect(allEven)  // only 0, which is even
            } else {
                #expect(countEven > 0)
                #expect(anyEven)
                #expect(!allEven)  // 1 is odd
            }
        }
    }
}

// MARK: - Drop/Prefix Tests

enum VectorDropPrefixTests {
    @Suite struct Drop {}
    @Suite struct Prefix {}
    @Suite struct Chaining {}
    @Suite struct Reversed {}
}

// MARK: - Drop Tests

extension VectorDropPrefixTests.Drop {

    @Test
    func `drop.first returns Vector with adjusted start (O(1))`() throws(VectorTestError) {
        let vector = try Vector(0..<10) { $0 }
        let dropped = vector.drop.first(3)

        // Verify it's still a vector with correct count
        #expect(dropped.count == 7)

        // Verify contents
        var results: [Int] = []
        let d = dropped
        d.forEach { results.append($0) }
        #expect(results == [3, 4, 5, 6, 7, 8, 9])
    }

    @Test
    func `drop.first with count >= size returns empty vector`() throws(VectorTestError) {
        let vector = try Vector(0..<5) { $0 }
        #expect(vector.drop.first(5).isEmpty)
        #expect(vector.drop.first(10).isEmpty)
    }

    @Test
    func `drop.first(0) returns equivalent vector`() throws(VectorTestError) {
        let vector = try Vector(0..<5) { $0 }
        let dropped = vector.drop.first(0)
        #expect(dropped.count == 5)
    }

    @Test
    func `drop.while returns array (O(n))`() throws(VectorTestError) {
        let vector = try Vector(0..<10) { $0 }
        let result = vector.drop.while { $0 < 5 }
        #expect(result == [5, 6, 7, 8, 9])
    }

    @Test
    func `drop.while with always-true predicate returns empty array`() throws(VectorTestError) {
        let vector = try Vector(0..<5) { $0 }
        #expect(vector.drop.while { _ in true } == [])
    }

    @Test
    func `drop.while with always-false predicate returns all elements`() throws(VectorTestError) {
        let vector = try Vector(0..<5) { $0 }
        #expect(vector.drop.while { _ in false } == [0, 1, 2, 3, 4])
    }

    @Test
    func `drop.first with transform`() throws(VectorTestError) {
        let vector = try Vector(0..<5) { $0 * 2 }
        let dropped = vector.drop.first(2)

        var results: [Int] = []
        let d = dropped
        d.forEach { results.append($0) }
        #expect(results == [4, 6, 8])
    }
}

// MARK: - Prefix Tests

extension VectorDropPrefixTests.Prefix {

    @Test
    func `prefix.first returns Vector with adjusted end (O(1))`() throws(VectorTestError) {
        let vector = try Vector(0..<10) { $0 }
        let prefixed = vector.prefix.first(3)

        // Verify it's still a vector with correct count
        #expect(prefixed.count == 3)

        // Verify contents
        var results: [Int] = []
        let p = prefixed
        p.forEach { results.append($0) }
        #expect(results == [0, 1, 2])
    }

    @Test
    func `prefix.first with count >= size returns equivalent vector`() throws(VectorTestError) {
        let vector = try Vector(0..<5) { $0 }
        #expect(vector.prefix.first(5).count == 5)
        #expect(vector.prefix.first(10).count == 5)
    }

    @Test
    func `prefix.first(0) returns empty vector`() throws(VectorTestError) {
        let vector = try Vector(0..<5) { $0 }
        #expect(vector.prefix.first(0).isEmpty)
    }

    @Test
    func `prefix.while returns array (O(n))`() throws(VectorTestError) {
        let vector = try Vector(0..<10) { $0 }
        let result = vector.prefix.while { $0 < 5 }
        #expect(result == [0, 1, 2, 3, 4])
    }

    @Test
    func `prefix.while with always-true predicate returns all elements`() throws(VectorTestError) {
        let vector = try Vector(0..<5) { $0 }
        #expect(vector.prefix.while { _ in true } == [0, 1, 2, 3, 4])
    }

    @Test
    func `prefix.while with always-false predicate returns empty array`() throws(VectorTestError) {
        let vector = try Vector(0..<5) { $0 }
        #expect(vector.prefix.while { _ in false } == [])
    }

    @Test
    func `prefix.first with transform`() throws(VectorTestError) {
        let vector = try Vector(0..<5) { $0 * 2 }
        let prefixed = vector.prefix.first(3)

        var results: [Int] = []
        let p = prefixed
        p.forEach { results.append($0) }
        #expect(results == [0, 2, 4])
    }
}

// MARK: - Chaining Tests

extension VectorDropPrefixTests.Chaining {

    @Test
    func `drop.first then prefix.first chains correctly (all O(1))`() throws(VectorTestError) {
        let vector = try Vector(0..<10) { $0 }
        let result = vector.drop.first(2).prefix.first(3)

        #expect(result.count == 3)

        var results: [Int] = []
        let r = result
        r.forEach { results.append($0) }
        #expect(results == [2, 3, 4])
    }

    @Test
    func `prefix.first then drop.first chains correctly`() throws(VectorTestError) {
        let vector = try Vector(0..<10) { $0 }
        let result = vector.prefix.first(5).drop.first(2)

        #expect(result.count == 3)

        var results: [Int] = []
        let r = result
        r.forEach { results.append($0) }
        #expect(results == [2, 3, 4])
    }

    @Test
    func `multiple drop.first calls accumulate correctly`() throws(VectorTestError) {
        let vector = try Vector(0..<10) { $0 }
        let result = vector.drop.first(2).drop.first(3)

        #expect(result.count == 5)

        var results: [Int] = []
        let r = result
        r.forEach { results.append($0) }
        #expect(results == [5, 6, 7, 8, 9])
    }

    @Test
    func `multiple prefix.first calls take minimum`() throws(VectorTestError) {
        let vector = try Vector(0..<10) { $0 }
        let result = vector.prefix.first(7).prefix.first(3)

        #expect(result.count == 3)

        var results: [Int] = []
        let r = result
        r.forEach { results.append($0) }
        #expect(results == [0, 1, 2])
    }

    @Test
    func `complex chaining maintains correct bounds`() throws(VectorTestError) {
        let vector = try Vector(0..<20) { $0 }
        let result = vector
            .drop.first(5)  // 5..<20
            .prefix.first(10)  // 5..<15
            .drop.first(2)  // 7..<15
            .prefix.first(5)  // 7..<12

        #expect(result.count == 5)

        var results: [Int] = []
        let r = result
        r.forEach { results.append($0) }
        #expect(results == [7, 8, 9, 10, 11])
    }
}

// MARK: - Reversed Tests

extension VectorDropPrefixTests.Reversed {

    @Test
    func `reversed drop.first skips from high end`() throws(VectorTestError) {
        let vector = try Vector(0..<10) { $0 }
        let reversed = vector.reversed()
        let dropped = reversed.drop.first(3)

        // Original: [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
        // After drop.first(3): [6, 5, 4, 3, 2, 1, 0]
        #expect(dropped.count == 7)

        var results: [Int] = []
        let d = dropped
        d.forEach { results.append($0) }
        #expect(results == [6, 5, 4, 3, 2, 1, 0])
    }

    @Test
    func `reversed prefix.first takes from high end`() throws(VectorTestError) {
        let vector = try Vector(0..<10) { $0 }
        let reversed = vector.reversed()
        let prefixed = reversed.prefix.first(3)

        // Original: [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
        // After prefix.first(3): [9, 8, 7]
        #expect(prefixed.count == 3)

        var results: [Int] = []
        let p = prefixed
        p.forEach { results.append($0) }
        #expect(results == [9, 8, 7])
    }

    @Test
    func `reversed drop.while works correctly`() throws(VectorTestError) {
        let vector = try Vector(0..<10) { $0 }
        let reversed = vector.reversed()

        // Iteration order: 9, 8, 7, 6, 5, 4, 3, 2, 1, 0
        // Drop while > 5: drops 9, 8, 7, 6, keeps [5, 4, 3, 2, 1, 0]
        let result = reversed.drop.while { $0 > 5 }
        #expect(result == [5, 4, 3, 2, 1, 0])
    }

    @Test
    func `reversed prefix.while works correctly`() throws(VectorTestError) {
        let vector = try Vector(0..<10) { $0 }
        let reversed = vector.reversed()

        // Iteration order: 9, 8, 7, 6, 5, 4, 3, 2, 1, 0
        // Prefix while > 5: takes [9, 8, 7, 6]
        let result = reversed.prefix.while { $0 > 5 }
        #expect(result == [9, 8, 7, 6])
    }

    @Test
    func `reversed empty vector drop/prefix`() throws(VectorTestError) {
        let vector = try Vector(0..<0) { $0 }
        let reversed = vector.reversed()

        #expect(reversed.drop.first(5).isEmpty)
        #expect(reversed.prefix.first(5).isEmpty)
        #expect(reversed.drop.while { _ in true } == [])
        #expect(reversed.prefix.while { _ in true } == [])
    }
}

// MARK: - Invariant Tests for Drop/Prefix

enum VectorDropPrefixInvariantTests {
    @Suite struct Invariants {}
}

extension VectorDropPrefixInvariantTests.Invariants {

    @Test
    func `INVARIANT: drop.first(n) + prefix.first(m) maintains correct total`() throws(VectorTestError) {
        let sizes: [Vector<UInt>.Index.Count] = [0, 1, 5, 20, 100]

        for size in sizes {
            let vector = try Vector(count: size)

            // Structurally meaningful: empty, minimal, exact, overflow
            let dropCandidates: [Vector<UInt>.Index.Count] = [0, 1, size, size + 5]

            for dropCount in dropCandidates {
                let afterDrop = vector.drop.first(dropCount)
                let remaining = size.subtract.saturating(dropCount)

                #expect(afterDrop.count == remaining)

                let prefixCandidates: [Vector<UInt>.Index.Count] = [0, 1, remaining, remaining + 5]

                for prefixCount in prefixCandidates {
                    let afterPrefix = afterDrop.prefix.first(prefixCount)
                    let expected = Swift.min(prefixCount, remaining)
                    #expect(afterPrefix.count == expected)
                }
            }
        }
    }

    @Test
    func `INVARIANT: drop.first preserves transform`() throws(VectorTestError) {
        let vector = try Vector(0..<10) { $0 * 3 + 1 }
        let dropped = vector.drop.first(3)

        var results: [Int] = []
        let d = dropped
        d.forEach { results.append($0) }

        // Indices 3, 4, 5, 6, 7, 8, 9 → transformed: 10, 13, 16, 19, 22, 25, 28
        #expect(results == [10, 13, 16, 19, 22, 25, 28])
    }

    @Test
    func `INVARIANT: prefix.first preserves transform`() throws(VectorTestError) {
        let vector = try Vector(0..<10) { $0 * 3 + 1 }
        let prefixed = vector.prefix.first(4)

        var results: [Int] = []
        let p = prefixed
        p.forEach { results.append($0) }

        // Indices 0, 1, 2, 3 → transformed: 1, 4, 7, 10
        #expect(results == [1, 4, 7, 10])
    }

    @Test
    func `INVARIANT: drop(0) and prefix(count) are identity operations`() throws(VectorTestError) {
        for size in [0, 1, 5, 20] {
            let vector = try Vector(0..<size) { $0 }

            // drop.first(0) should be identity
            let afterDrop0 = vector.drop.first(0)
            #expect(afterDrop0.count == vector.count)

            // prefix.first(count) should be identity
            let afterPrefixAll = vector.prefix.first(vector.count)
            #expect(afterPrefixAll.count == vector.count)

            // prefix.first(count + 100) saturates back to count (still identity)
            let afterPrefixMore = vector.prefix.first(vector.count + Vector<Int>.Index.Count(100))
            #expect(afterPrefixMore.count == vector.count)
        }
    }

    @Test
    func `INVARIANT: order of operations matters`() throws(VectorTestError) {
        let vector = try Vector(0..<10) { $0 }

        // drop(3).prefix(4) vs prefix(4).drop(3) should differ
        let dropThenPrefix = vector.drop.first(3).prefix.first(4)
        let prefixThenDrop = vector.prefix.first(4).drop.first(3)

        var dtp: [Int] = []
        let dtpVector = dropThenPrefix
        dtpVector.forEach { dtp.append($0) }

        var ptd: [Int] = []
        let ptdVector = prefixThenDrop
        ptdVector.forEach { ptd.append($0) }

        // drop(3).prefix(4): [3, 4, 5, 6]
        // prefix(4).drop(3): [3]
        #expect(dtp == [3, 4, 5, 6])
        #expect(ptd == [3])
    }
}

// MARK: - Cardinal Distance Invariant Tests
//
// These tests verify the principled approach of using cardinal distance
// (Ordinal.distance.forward) instead of affine subtraction
// for computing vector counts. Cardinal distance handles the full UInt range.

enum VectorCardinalDistanceTests {
    @Suite struct Invariants {}
    @Suite struct LargeVectors {}
}

extension VectorCardinalDistanceTests.Invariants {
    @Test(arguments: [
        (0, 0),  // empty
        (0, 1),  // single element
        (0, 100),  // normal vector
        (50, 150),  // offset vector
        (1000, 1000),  // empty at offset
    ])
    func `INVARIANT: count equals cardinal distance between positions`(start: Vector<UInt>.Index, end: Vector<UInt>.Index) throws(Vector<UInt>.Error) {
        // SAFETY: test fixtures guarantee end >= start, so `.unchecked(to:)`
        // is the proven-monotonic call site per ordinal-primitives' docs.
        let cardinalDistance = start.position.distance.unchecked(to: end.position)

        let vector = try Vector(start: start, end: end)

        #expect(vector.count == Vector<UInt>.Index.Count(cardinalDistance))
    }

    @Test(arguments: [
        (0, 0),
        (0, 1),
        (0, 10),
        (5, 15),
        (100, 100),
        (100, 105),
    ])
    func `INVARIANT: count matches iteration count exactly`(start: Vector<UInt>.Index, end: Vector<UInt>.Index) throws(Vector<UInt>.Error) {
        let vector = try Vector(start: start, end: end)

        var iterationCount: Vector<UInt>.Index.Count = 0
        vector.forEach { _ in iterationCount += 1 }

        #expect(vector.count == iterationCount)
    }

    @Test
    func `INVARIANT: count preserved through drop and prefix`() {
        let vector: Vector = Vector(count: 100)

        let dropped = vector.drop.first(30)
        #expect(dropped.count == 70)

        // SAFETY: drop preserves dropped.start <= dropped.end by construction.
        let droppedDistance = dropped.start.position.distance.unchecked(to: dropped.end.position)
        #expect(dropped.count == Vector<UInt>.Index.Count(droppedDistance))

        let prefixed = vector.prefix.first(40)
        #expect(prefixed.count == 40)

        // SAFETY: prefix preserves prefixed.start <= prefixed.end by construction.
        let prefixedDistance = prefixed.start.position.distance.unchecked(to: prefixed.end.position)
        #expect(prefixed.count == Vector<UInt>.Index.Count(prefixedDistance))
    }

    @Test
    func `INVARIANT: reversed vector preserves count`() {
        let vector: Vector = Vector(count: 100)
        let reversed = vector.reversed()

        #expect(reversed.count == vector.count)

        var forwardCount: UInt = 0
        vector.forEach { _ in forwardCount += 1 }

        var reversedCount: UInt = 0
        reversed.forEach { _ in reversedCount += 1 }

        #expect(forwardCount == reversedCount)
    }
}

extension VectorCardinalDistanceTests.LargeVectors {

    @Test
    func `INVARIANT: vectors exceeding Int.max distance work`() {
        // Cardinal distance handles full UInt range.
        // Affine subtraction would fail for distances > Int.max.

        let intMax: Vector<UInt>.Index.Count = Vector<UInt>.Index.Count(UInt(Int.max))

        // Distance exactly Int.max
        let vectorAtLimit: Vector = Vector(count: intMax)
        #expect(vectorAtLimit.count == intMax)

        // Distance Int.max + 1 (would FAIL with affine subtraction)
        let beyondIntMax = intMax + .one
        let vectorBeyond: Vector = Vector(count: beyondIntMax)
        #expect(vectorBeyond.count == beyondIntMax)

        // Distance Int.max + 1000
        let wellBeyond: Vector<UInt>.Index.Count = intMax + Vector<UInt>.Index.Count(1000)
        let vectorWellBeyond: Vector = Vector(count: wellBeyond)
        #expect(vectorWellBeyond.count == wellBeyond)
    }

    @Test
    func `INVARIANT: offset vectors with large distances work`() {
        let intMax = UInt(Int.max)
        let start: UInt = 1000
        let distance = intMax + 500
        let end = start + distance

        let vector = Vector(start..<end) { $0 }

        #expect(vector.count == Vector<UInt>.Index.Count(distance))

        // SAFETY: `Vector(start..<end)` preserves `vector.start <= vector.end`.
        let cardinalDistance = vector.start.position.distance.unchecked(to: vector.end.position)
        #expect(vector.count == Vector<UInt>.Index.Count(cardinalDistance))
    }

    @Test
    func `INVARIANT: vectors near UInt.max work`() {
        let max = UInt.max

        // Vector ending near UInt.max
        let vectorNearMax = Vector((max - 100)..<max) { $0 }
        #expect(vectorNearMax.count == Vector<UInt>.Index.Count(100))

        // Empty vector near UInt.max
        let emptyNearMax = Vector((max - 1)..<(max - 1)) { $0 }
        #expect(emptyNearMax.isEmpty)
        #expect(emptyNearMax.count == .zero)
    }

    @Test
    func `INVARIANT: maximum possible vector 0 to UInt.max`() {
        // The largest possible vector
        let vector = Vector(0..<UInt.max) { $0 }

        #expect(vector.count == Vector<UInt>.Index.Count(UInt.max))

        // SAFETY: `Vector(0..<UInt.max)` preserves `vector.start <= vector.end`.
        let distance = vector.start.position.distance.unchecked(to: vector.end.position)
        #expect(distance.rawValue == UInt.max)
    }

    @Test
    func `INVARIANT: drop and prefix near UInt.max`() {
        let max = UInt.max
        let vector = Vector((max - 50)..<max) { $0 }

        let dropped = vector.drop.first(20)
        #expect(dropped.count == 30)

        let prefixed = vector.prefix.first(15)
        #expect(prefixed.count == 15)
    }
}
