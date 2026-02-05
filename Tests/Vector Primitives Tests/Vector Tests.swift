// Vector Tests.swift
// Tests for Vector (heap-allocated)

import Testing

@testable import Vector_Primitives
import Vector_Primitives_Test_Support

// MARK: - Vector Unit Tests

@Suite("Vector Unit")
struct VectorUnitTests {
    typealias IntVec3 = Vector<Int, 3>
    typealias DoubleVec2 = Vector<Double, 2>

    @Test("construction from InlineArray")
    func constructionFromInlineArray() {
        let v = IntVec3([1, 2, 3])
        #expect(v[0] == 1)
        #expect(v[1] == 2)
        #expect(v[2] == 3)
    }

    @Test("construction with repeating value")
    func constructionWithRepeatingValue() {
        let v = IntVec3(repeating: 42)
        #expect(v[0] == 42)
        #expect(v[1] == 42)
        #expect(v[2] == 42)
    }

    @Test("static dimension property")
    func staticDimensionProperty() {
        #expect(IntVec3.dimension == 3)
        #expect(DoubleVec2.dimension == 2)
    }

    @Test("subscript get and set")
    func subscriptGetAndSet() {
        var v = IntVec3([1, 2, 3])
        #expect(v[0] == 1)
        v[0] = 100
        #expect(v[0] == 100)
    }

    @Test("element(at:) valid index")
    func elementAtValidIndex() {
        let v = IntVec3([1, 2, 3])
        let idx0: IntVec3.Index = 0
        let idx1: IntVec3.Index = 1
        let idx2: IntVec3.Index = 2
        #expect(v.element(at: idx0) == 1)
        #expect(v.element(at: idx1) == 2)
        #expect(v.element(at: idx2) == 3)
    }

    @Test("elements property get")
    func elementsPropertyGet() {
        let v = IntVec3([1, 2, 3])
        let elements = v.elements
        #expect(elements[0] == 1)
        #expect(elements[1] == 2)
        #expect(elements[2] == 3)
    }

    @Test("elements property set")
    func elementsPropertySet() {
        var v = IntVec3([1, 2, 3])
        v.elements = [10, 20, 30]
        #expect(v[0] == 10)
        #expect(v[1] == 20)
        #expect(v[2] == 30)
    }

    @Test("forEach iterates all elements")
    func forEachIteratesAllElements() {
        let v = IntVec3([10, 20, 30])
        var sum = 0
        v.forEach { element in
            sum += element
        }
        #expect(sum == 60)
    }

    @Test("withElement borrowing access")
    func withElementBorrowingAccess() {
        let v = IntVec3([10, 20, 30])
        let idx: IntVec3.Index = 1
        let result = v.withElement(at: idx) { element in
            element * 2
        }
        #expect(result == 40)
    }

    @Test("equality")
    func equality() {
        let a = IntVec3([1, 2, 3])
        let b = IntVec3([1, 2, 3])
        let c = IntVec3([1, 2, 4])
        #expect(a == b)
        #expect(a != c)
    }

    @Test("hashable")
    func hashable() {
        let a = IntVec3([1, 2, 3])
        let b = IntVec3([1, 2, 3])
        #expect(a.hashValue == b.hashValue)
    }

    @Test("span read access")
    func spanReadAccess() {
        let v = IntVec3([10, 20, 30])
        var sum = 0
        let s = v.span
        for i in s.indices {
            sum += s[i]
        }
        #expect(sum == 60)
    }

    @Test("span count matches dimension")
    func spanCountMatchesDimension() {
        let v = IntVec3([1, 2, 3])
        #expect(v.span.count == 3)
    }
}

// MARK: - Vector Edge Case Tests

@Suite("Vector EdgeCase")
struct VectorEdgeCaseTests {
    @Test("single element vector")
    func singleElementVector() {
        let v = Vector<Int, 1>([42])
        #expect(Vector<Int, 1>.dimension == 1)
        #expect(v[0] == 42)
        let idx: Vector<Int, 1>.Index = 0
        #expect(v.element(at: idx) == 42)
    }

    @Test("double values precision")
    func doubleValuesPrecision() {
        let v = Vector<Double, 2>([3.14, 2.71])
        #expect(v[0] == 3.14)
        #expect(v[1] == 2.71)
    }

    @Test("large dimension vector")
    func largeDimensionVector() {
        let v = Vector<Int, 10>(repeating: 7)
        #expect(Vector<Int, 10>.dimension == 10)
        for i in try! (0..<10).map(Vector<Int, 10>.Index.init) {
            #expect(v[i] == 7)
        }
    }
}

// MARK: - Vector Performance Tests

@Suite("Vector Performance")
struct VectorPerformanceTests {
    @Test("vector creation")
    func vectorCreation() {
        for _ in 0..<1000 {
            let v = Vector<Int, 3>([1, 2, 3])
            _ = v[0]
        }
    }

    @Test("element access")
    func elementAccess() {
        let v = Vector<Int, 3>([1, 2, 3])
        var sum = 0
        for _ in 0..<10000 {
            sum += v[0] + v[1] + v[2]
        }
        #expect(sum == 60000)
    }
}
