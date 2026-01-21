// Vector.Inline Tests.swift
// Tests for Vector.Inline (inline storage)

import Testing

@testable import Vector_Primitives

// MARK: - Vector.Inline Unit Tests

@Suite("Vector.Inline Unit")
struct VectorInlineUnitTests {
    typealias IntVec3 = Vector<Int, 3>.Inline
    typealias DoubleVec2 = Vector<Double, 2>.Inline

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
        #expect(Vector<Int, 1>.Inline.dimension == 1)
        #expect(Vector<Int, 10>.Inline.dimension == 10)
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
        #expect(v.element(at: 0) == 1)
        #expect(v.element(at: 1) == 2)
        #expect(v.element(at: 2) == 3)
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
        let result = v.withElement(at: 1) { element in
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

    @Test("mutableSpan write access")
    func mutableSpanWriteAccess() {
        var v = IntVec3([1, 2, 3])
        v.mutableSpan[0] = 100
        v.mutableSpan[1] = 200
        v.mutableSpan[2] = 300
        #expect(v[0] == 100)
        #expect(v[1] == 200)
        #expect(v[2] == 300)
    }
}

// MARK: - Vector.Inline Edge Case Tests

@Suite("Vector.Inline EdgeCase")
struct VectorInlineEdgeCaseTests {
    @Test("element(at:) invalid index returns nil")
    func elementAtInvalidIndexReturnsNil() {
        let v = Vector<Int, 3>.Inline([1, 2, 3])
        #expect(v.element(at: -1) == nil)
        #expect(v.element(at: 3) == nil)
        #expect(v.element(at: 100) == nil)
    }

    @Test("single element vector")
    func singleElementVector() {
        typealias IntVec1 = Vector<Int, 1>.Inline
        let v = IntVec1([42])
        #expect(IntVec1.dimension == 1)
        #expect(v[0] == 42)
        #expect(v.element(at: 0) == 42)
        #expect(v.element(at: 1) == nil)
    }

    @Test("double values precision")
    func doubleValuesPrecision() {
        let v = Vector<Double, 2>.Inline([3.14, 2.71])
        #expect(v[0] == 3.14)
        #expect(v[1] == 2.71)
    }

    @Test("large dimension vector")
    func largeDimensionVector() {
        let v = Vector<Int, 10>.Inline(repeating: 7)
        #expect(Vector<Int, 10>.Inline.dimension == 10)
        for i in v.span.indices {
            #expect(v.span[i] == 7)
        }
    }
}

// MARK: - Vector.Inline Performance Tests

@Suite("Vector.Inline Performance")
struct VectorInlinePerformanceTests {
    @Test("inline vector creation")
    func inlineVectorCreation() {
        for _ in 0..<1000 {
            let v = Vector<Int, 3>.Inline([1, 2, 3])
            _ = v[0]
        }
    }

    @Test("inline element access")
    func inlineElementAccess() {
        let v = Vector<Int, 3>.Inline([1, 2, 3])
        var sum = 0
        for _ in 0..<10000 {
            sum += v[0] + v[1] + v[2]
        }
        #expect(sum == 60000)
    }
}
