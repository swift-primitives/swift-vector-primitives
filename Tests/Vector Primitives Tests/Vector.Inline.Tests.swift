// Vector.Inline.Tests.swift
// Tests for Vector.Inline

import Testing

@testable import Vector_Primitives

@Suite
struct `Vector.Inline Tests` {
    typealias IntVec3 = Vector<Int, 3>.Inline
    typealias DoubleVec2 = Vector<Double, 2>.Inline

    // MARK: - Construction

    @Test
    func `construction from InlineArray`() {
        let v = IntVec3([1, 2, 3])
        #expect(v[0] == 1)
        #expect(v[1] == 2)
        #expect(v[2] == 3)
    }

    @Test
    func `construction with repeating value`() {
        let v = IntVec3(repeating: 42)
        #expect(v[0] == 42)
        #expect(v[1] == 42)
        #expect(v[2] == 42)
    }

    // MARK: - Dimension

    @Test
    func `static dimension property`() {
        #expect(IntVec3.dimension == 3)
        #expect(DoubleVec2.dimension == 2)
        #expect(Vector<Int, 1>.Inline.dimension == 1)
        #expect(Vector<Int, 10>.Inline.dimension == 10)
    }

    // MARK: - Element Access

    @Test
    func `elements property get`() {
        let v = IntVec3([1, 2, 3])
        let elements = v.elements
        #expect(elements[0] == 1)
        #expect(elements[1] == 2)
        #expect(elements[2] == 3)
    }

    @Test
    func `elements property set`() {
        var v = IntVec3([1, 2, 3])
        v.elements = [10, 20, 30]
        #expect(v[0] == 10)
        #expect(v[1] == 20)
        #expect(v[2] == 30)
    }

    @Test
    func `subscript get and set`() {
        var v = IntVec3([1, 2, 3])
        #expect(v[0] == 1)
        v[0] = 100
        #expect(v[0] == 100)
    }

    @Test
    func `element(at:) valid index`() {
        let v = IntVec3([1, 2, 3])
        #expect(v.element(at: 0) == 1)
        #expect(v.element(at: 1) == 2)
        #expect(v.element(at: 2) == 3)
    }

    @Test
    func `element(at:) invalid index returns nil`() {
        let v = IntVec3([1, 2, 3])
        #expect(v.element(at: -1) == nil)
        #expect(v.element(at: 3) == nil)
        #expect(v.element(at: 100) == nil)
    }

    // MARK: - Iteration

    @Test
    func `forEach iterates all elements`() {
        let v = IntVec3([10, 20, 30])
        var sum = 0
        v.forEach { element in
            sum += element
        }
        #expect(sum == 60)
    }

    @Test
    func `withElement borrowing access`() {
        let v = IntVec3([10, 20, 30])
        let result = v.withElement(at: 1) { element in
            element * 2
        }
        #expect(result == 40)
    }

    // MARK: - Equatable

    @Test
    func `equality`() {
        let a = IntVec3([1, 2, 3])
        let b = IntVec3([1, 2, 3])
        let c = IntVec3([1, 2, 4])
        #expect(a == b)
        #expect(a != c)
    }

    // MARK: - Hashable

    @Test
    func `hashable`() {
        let a = IntVec3([1, 2, 3])
        let b = IntVec3([1, 2, 3])
        #expect(a.hashValue == b.hashValue)
    }

    // MARK: - Edge Cases

    @Test
    func `single element vector`() {
        typealias IntVec1 = Vector<Int, 1>.Inline
        let v = IntVec1([42])
        #expect(IntVec1.dimension == 1)
        #expect(v[0] == 42)
        #expect(v.element(at: 0) == 42)
        #expect(v.element(at: 1) == nil)
    }

    @Test
    func `double values`() {
        let v = DoubleVec2([3.14, 2.71])
        #expect(v[0] == 3.14)
        #expect(v[1] == 2.71)
    }

    // MARK: - Span Access

    @Test
    func `span read access`() {
        let v = IntVec3([10, 20, 30])
        var sum = 0
        let s = v.span
        for i in s.indices {
            sum += s[i]
        }
        #expect(sum == 60)
    }

    @Test
    func `span count matches dimension`() {
        let v = IntVec3([1, 2, 3])
        #expect(v.span.count == 3)
    }

    @Test
    func `mutableSpan write access`() {
        var v = IntVec3([1, 2, 3])
        v.mutableSpan[0] = 100
        v.mutableSpan[1] = 200
        v.mutableSpan[2] = 300
        #expect(v[0] == 100)
        #expect(v[1] == 200)
        #expect(v[2] == 300)
    }
}

// MARK: - Base Vector Tests

@Suite
struct `Vector Tests` {
    typealias IntVec3 = Vector<Int, 3>
    typealias DoubleVec2 = Vector<Double, 2>

    // MARK: - Construction

    @Test
    func `construction from InlineArray`() {
        let v = IntVec3([1, 2, 3])
        #expect(v[0] == 1)
        #expect(v[1] == 2)
        #expect(v[2] == 3)
    }

    @Test
    func `construction with repeating value`() {
        let v = IntVec3(repeating: 42)
        #expect(v[0] == 42)
        #expect(v[1] == 42)
        #expect(v[2] == 42)
    }

    // MARK: - Dimension

    @Test
    func `static dimension property`() {
        #expect(IntVec3.dimension == 3)
        #expect(DoubleVec2.dimension == 2)
    }

    // MARK: - Element Access

    @Test
    func `subscript get and set`() {
        var v = IntVec3([1, 2, 3])
        #expect(v[0] == 1)
        v[0] = 100
        #expect(v[0] == 100)
    }

    @Test
    func `element(at:) valid index`() {
        let v = IntVec3([1, 2, 3])
        #expect(v.element(at: 0) == 1)
        #expect(v.element(at: 1) == 2)
        #expect(v.element(at: 2) == 3)
    }

    @Test
    func `element(at:) invalid index returns nil`() {
        let v = IntVec3([1, 2, 3])
        #expect(v.element(at: -1) == nil)
        #expect(v.element(at: 3) == nil)
    }

    @Test
    func `elements property`() {
        let v = IntVec3([1, 2, 3])
        let elements = v.elements
        #expect(elements[0] == 1)
        #expect(elements[1] == 2)
        #expect(elements[2] == 3)
    }

    // MARK: - Equatable

    @Test
    func `equality`() {
        let a = IntVec3([1, 2, 3])
        let b = IntVec3([1, 2, 3])
        let c = IntVec3([1, 2, 4])
        #expect(a == b)
        #expect(a != c)
    }

    // MARK: - Hashable

    @Test
    func `hashable`() {
        let a = IntVec3([1, 2, 3])
        let b = IntVec3([1, 2, 3])
        #expect(a.hashValue == b.hashValue)
    }

    // MARK: - Span Access

    @Test
    func `span read access`() {
        let v = IntVec3([10, 20, 30])
        var sum = 0
        let s = v.span
        for i in s.indices {
            sum += s[i]
        }
        #expect(sum == 60)
    }

    @Test
    func `span count matches dimension`() {
        let v = IntVec3([1, 2, 3])
        #expect(v.span.count == 3)
    }
}
