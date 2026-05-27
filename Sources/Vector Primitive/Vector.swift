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

public import Index_Primitives
public import Property_Primitives

/// A functional vector that generates `~Copyable` values on demand from a finite integer domain.
///
/// `Vector<Bound>` is semantically `Vec n A = Fin n -> A` — a representable/Naperian functor.
/// It stores integer bounds internally and applies a transformation function to produce typed
/// bounds. This enables iteration over `~Copyable` types without requiring `Sequence` conformance.
///
/// ## The Index Domain Concept
///
/// `Vector` operates over a **Copyable index domain** (`Vector<Bound>.Index`), from which
/// `~Copyable` bounds are generated on demand. This separation is the architectural core:
///
/// | Aspect | Index Domain | Bound Projection |
/// |--------|--------------|------------------|
/// | Type | `Vector<Bound>.Index` (Copyable) | `Bound: ~Copyable` |
/// | Storage | Stored directly | Never stored |
/// | Count | O(1): cached at init | N/A |
///
/// ## Regeneration Semantics
///
/// Each iteration step or subscript access calls the transform function.
/// Values are **not cached** — they are created fresh at each access.
///
/// ## Conditional Sequence.Protocol Conformance
///
/// `Vector` conditionally conforms to `Sequence.Protocol` when `Bound: Copyable`:
///
/// | Bound | Sequence.Protocol | Available Operations |
/// |-------|-------------------|---------------------|
/// | `Copyable` | Conforms | `.satisfies.all`, `.first`, `.countWhere`, `.reduce`, `.contains` |
/// | `~Copyable` | Does not conform | `.forEach`, `.drain` only |
///
/// This conditional conformance exists because `Sequence.Protocol.Element`
/// implicitly requires `Copyable` per SE-0427.
///
/// For `~Copyable` bounds, use the closure-based `.forEach` and `.drain` patterns.
///
/// ## Why Property.Inout (Not Direct Methods)
///
/// The `.forEach` and `.drain` patterns use `Property.Inout` because it is
/// **mandatory**, not stylistic. Property.Inout enables consuming iteration
/// while preserving borrow checking and lifetime guarantees. Direct mutating
/// methods would require `var` binding at call sites and lose lifetime safety.
///
/// ## Iteration Patterns
///
/// ```swift
/// var vector = Vector(count: try .init(10)) { position in
///     Index<Node>(_unchecked: position.position)
/// }
///
/// // Borrowing iteration (vector survives)
/// vector.forEach { index in
///     print(index)
/// }
///
/// // Consuming iteration (vector becomes empty)
/// vector.drain { index in
///     consume(index)
/// }
///
/// // Reversed iteration
/// var reversed = vector.reversed()
/// reversed.forEach { index in
///     print(index)  // Prints in reverse order
/// }
///
/// // Manual iteration
/// var iterator = vector.makeIterator()
/// while let index = iterator.next() {
///     process(index)
/// }
/// ```
///
/// ## Design Note
///
/// The `Iterator`, `Reversed`, `ForEach`, `Drain`, and `Error` types are declared
/// inline (not in extensions) so that they properly inherit the `~Copyable`
/// constraint from `Bound` per [PATTERN-022]. This matches the pattern used by
/// `Array.Static` and `Array.Storage`.
public struct Vector<Bound: ~Copyable> {

    // MARK: - Type Aliases and Nested Types

    /// The phantom-typed index used to address positions in the vector domain.
    public typealias Index = Index_Primitives.Index<Vector<Bound>>

    /// Tag type for `.forEach` property extensions.
    ///
    /// Enables borrowing iteration via the `.forEach { }` pattern.
    public enum ForEach {}

    /// Tag type for `.drain` property extensions.
    ///
    /// Enables consuming iteration via the `.drain { }` pattern.
    public enum Drain {}

    /// Errors that can occur in vector operations.
    public enum Error: Swift.Error, Hashable, Sendable {
        /// The bounds are invalid (start > end).
        case invalidBounds(start: Index, end: Index)
    }

    // MARK: - Stored Properties

    /// The first index in the vector domain (inclusive).
    public var start: Index

    /// The end index in the vector domain (exclusive).
    public var end: Index

    @usableFromInline
    var _count: Index.Count

    /// The number of elements in the vector domain.
    @inlinable
    public var count: Index.Count {
        _read { yield _count }
        _modify { yield &_count }
    }

    @usableFromInline
    let transform: @Sendable (Index) -> Bound

    // MARK: - Nested Iterator

    /// Iterator for `Vector`.
    ///
    /// Declared inline to inherit `Bound: ~Copyable` from the outer type.
    public struct Iterator: ~Copyable {
        @usableFromInline
        var current: Index

        @usableFromInline
        let end: Index

        @usableFromInline
        let transform: @Sendable (Index) -> Bound

        @inlinable
        init(current: Index, end: Index, transform: @escaping @Sendable (Index) -> Bound) {
            self.current = current
            self.end = end
            self.transform = transform
        }

        /// Advances to the next element and returns it, or `nil` if exhausted.
        @inlinable
        public mutating func next() -> Bound? {
            guard current < end else { return nil }
            let result = transform(current)
            // Index<Bound> += .one resolves to the non-throwing
            // `Ordinal.Protocol.+= (inout Self, Count)` operator.
            current += .one
            return result
        }
    }

    // MARK: - Nested Reversed

    /// A reversed view of a vector.
    ///
    /// Iterates from `end-1` down to `start` (inclusive on both ends in the
    /// transformed result).
    ///
    /// Declared inline to inherit `Bound: ~Copyable` from the outer type.
    public struct Reversed {
        @usableFromInline
        var start: Index

        @usableFromInline
        var end: Index

        @usableFromInline
        var _count: Index.Count

        /// The number of elements in the reversed vector domain.
        @inlinable
        public var count: Index.Count {
            _read { yield _count }
            _modify { yield &_count }
        }

        @usableFromInline
        let transform: @Sendable (Index) -> Bound

        /// Iterator for `Vector.Reversed`.
        ///
        /// Uses a check-before-decrement pattern with an `exhausted` flag
        /// to avoid underflow when reaching index zero.
        public struct Iterator: ~Copyable {
            @usableFromInline
            var current: Index

            @usableFromInline
            let start: Index

            @usableFromInline
            let transform: @Sendable (Index) -> Bound

            @usableFromInline
            var exhausted: Bool

            @inlinable
            init(start: Index, end: Index, transform: @escaping @Sendable (Index) -> Bound) {
                self.start = start
                self.transform = transform

                if start == end {
                    self.current = start
                    self.exhausted = true
                } else {
                    // SAFETY: `start < end` (else branch) proves `end > .zero`,
                    // so `end.predecessor.exact()` cannot underflow. We use
                    // `do/catch` with an `exhausted = true` fallback instead of
                    // `try!` to satisfy swift-format; the catch is unreachable.
                    do throws(Ordinal.Error) {
                        self.current = try end.predecessor.exact()
                        self.exhausted = false
                    } catch {
                        self.current = start
                        self.exhausted = true
                    }
                }
            }

            /// Advances to the next element and returns it, or `nil` if exhausted.
            @inlinable
            public mutating func next() -> Bound? {
                guard !exhausted else { return nil }

                let result = transform(current)

                if current == start {
                    exhausted = true
                } else {
                    // SAFETY: `current > start >= .zero` proves `current > .zero`,
                    // so `current.predecessor.exact()` cannot underflow. We use
                    // `do/catch` with an `exhausted = true` fallback instead of
                    // `try!` to satisfy swift-format; the catch is unreachable.
                    do throws(Ordinal.Error) {
                        current = try current.predecessor.exact()
                    } catch {
                        exhausted = true
                    }
                }

                return result
            }
        }

        @usableFromInline
        init(
            start: Index,
            end: Index,
            count: Index.Count,
            transform: @escaping @Sendable (Index) -> Bound
        ) {
            self.start = start
            self.end = end
            self._count = count
            self.transform = transform
        }

        @usableFromInline
        init(__unchecked: Void, start: Index, end: Index, transform: @escaping @Sendable (Index) -> Bound) {
            self.start = start
            self.end = end
            // SAFETY: `__unchecked` caller guarantees `end >= start`, so
            // `start.position.distance.forward(to: end.position)` cannot throw
            // `Ordinal.Error.notForward`. We use `do/catch` with a `fatalError`
            // on the unreachable path instead of `try!` to satisfy swift-format.
            do throws(Ordinal.Error) {
                self._count = Index.Count(try start.position.distance.forward(to: end.position))
            } catch {
                fatalError("invariant violation: \(error)")
            }
            self.transform = transform
        }

        /// Whether the reversed vector contains zero elements.
        @inlinable
        public var isEmpty: Bool { count == .zero }

        /// Returns an iterator over the reversed vector's bounds.
        @inlinable
        public consuming func makeIterator() -> Iterator {
            Iterator(start: start, end: end, transform: transform)
        }

        // MARK: Internal Iteration

        @inlinable
        mutating func _borrowingForEach<E: Swift.Error>(_ body: (borrowing Bound) throws(E) -> Void) throws(E) {
            guard !isEmpty else { return }
            // SAFETY: `!isEmpty` proves `end > start >= .zero`, so
            // `end.predecessor.exact()` cannot underflow. `do/catch` with
            // an early return on the unreachable path replaces `try!`.
            let initial: Index
            do throws(Ordinal.Error) {
                initial = try end.predecessor.exact()
            } catch {
                return
            }
            var i = initial
            while i >= start {
                let bound = transform(i)
                try body(bound)
                if i == start { break }
                // SAFETY: `i > start >= .zero` proves `i > .zero`, so
                // `i.predecessor.exact()` cannot underflow. We break on
                // the unreachable path instead of using `try!`.
                do throws(Ordinal.Error) {
                    i = try i.predecessor.exact()
                } catch {
                    break
                }
            }
        }

        @inlinable
        mutating func _consumingDrain(_ body: (consuming Bound) -> Void) {
            guard !isEmpty else { return }
            // SAFETY: `!isEmpty` proves `end > start >= .zero`, so
            // `end.predecessor.exact()` cannot underflow. `do/catch` with
            // an early return on the unreachable path replaces `try!`.
            let initial: Index
            do throws(Ordinal.Error) {
                initial = try end.predecessor.exact()
            } catch {
                return
            }
            var i = initial
            while i >= start {
                body(transform(i))
                if i == start { break }
                // SAFETY: `i > start >= .zero` proves `i > .zero`, so
                // `i.predecessor.exact()` cannot underflow. We break on
                // the unreachable path instead of using `try!`.
                do throws(Ordinal.Error) {
                    i = try i.predecessor.exact()
                } catch {
                    break
                }
            }
            start = end
            count = .zero
        }

        // MARK: Property Accessors

        /// Accessor for `.forEach { }` borrowing iteration over the reversed vector.
        @inlinable
        public var forEach: Property<ForEach, Self> {
            Property(self)
        }

        /// Accessor for `.drain { }` consuming iteration over the reversed vector.
        @inlinable
        public var drain: Property<Drain, Self>.Inout {
            mutating _read {
                yield Property<Drain, Self>.Inout(&self)
            }
            mutating _modify {
                var accessor = Property<Drain, Self>.Inout(&self)
                yield &accessor
            }
        }
    }

    // MARK: - Initializers

    /// Creates a vector from zero to count.
    @inlinable
    public init(
        count: Index.Count,
        transform: @escaping @Sendable (Index) -> Bound
    ) {
        self.start = .zero
        self.end = .zero + count
        self._count = count
        self.transform = transform
    }

    /// Creates a vector with explicit bounds.
    ///
    /// - Throws: `Vector.Error.invalidBounds` if start > end.
    @inlinable
    public init(
        start: Index,
        end: Index,
        transform: @escaping @Sendable (Index) -> Bound
    ) throws(Self.Error) {
        guard start <= end else {
            throw .invalidBounds(start: start, end: end)
        }
        self.start = start
        self.end = end
        // SAFETY: `start <= end` (guard above) proves
        // `start.position.distance.forward(to: end.position)` cannot throw
        // `Ordinal.Error.notForward`. `do/catch` with `fatalError` on the
        // unreachable path replaces `try!` to satisfy swift-format.
        do throws(Ordinal.Error) {
            self._count = Index.Count(try start.position.distance.forward(to: end.position))
        } catch {
            fatalError("invariant violation: \(error)")
        }
        self.transform = transform
    }

    /// Internal unchecked initializer for operations that have already validated bounds.
    @usableFromInline
    package init(
        __unchecked: Void,
        start: Index,
        end: Index,
        transform: @escaping @Sendable (Index) -> Bound
    ) {
        self.start = start
        self.end = end
        // SAFETY: `__unchecked` caller guarantees `end >= start`, so
        // `start.position.distance.forward(to: end.position)` cannot throw
        // `Ordinal.Error.notForward`. `do/catch` with `fatalError` on the
        // unreachable path replaces `try!` to satisfy swift-format.
        do throws(Ordinal.Error) {
            self._count = Index.Count(try start.position.distance.forward(to: end.position))
        } catch {
            fatalError("invariant violation: \(error)")
        }
        self.transform = transform
    }

    // MARK: - Properties

    /// Whether the vector contains zero elements.
    @inlinable
    public var isEmpty: Bool { count == .zero }

    // MARK: - Iterator Factory

    /// Returns an iterator over the vector's bounds.
    @inlinable
    public consuming func makeIterator() -> Iterator {
        Iterator(current: start, end: end, transform: transform)
    }

    // MARK: - Reversed Factory

    /// Returns a reversed view of the vector that iterates from end to start.
    @inlinable
    public consuming func reversed() -> Reversed {
        Reversed(start: start, end: end, count: count, transform: transform)
    }

    // MARK: - Internal Iteration

    @inlinable
    mutating func _borrowingForEach<E: Swift.Error>(_ body: (borrowing Bound) throws(E) -> Void) throws(E) {
        var i = start
        while i < end {
            let bound = transform(i)
            try body(bound)
            // Index<Bound> += .one resolves to the non-throwing
            // `Ordinal.Protocol.+= (inout Self, Count)` operator.
            i += .one
        }
    }

    @inlinable
    mutating func _consumingDrain(_ body: (consuming Bound) -> Void) {
        var i = start
        while i < end {
            body(transform(i))
            // Index<Bound> += .one resolves to the non-throwing
            // `Ordinal.Protocol.+= (inout Self, Count)` operator.
            i += .one
        }
        start = end
        count = .zero
    }

    // MARK: - Property Accessors

    /// Accessor for `.forEach { }` borrowing iteration over the vector.
    @inlinable
    public var forEach: Property<ForEach, Self> {
        Property(self)
    }

    /// Accessor for `.drain { }` consuming iteration over the vector.
    @inlinable
    public var drain: Property<Drain, Self>.Inout {
        mutating _read {
            yield Property<Drain, Self>.Inout(&self)
        }
        mutating _modify {
            var accessor = Property<Drain, Self>.Inout(&self)
            yield &accessor
        }
    }
}

// MARK: - Sendable

extension Vector: Sendable where Bound: Sendable {}
extension Vector.Iterator: Sendable where Bound: Sendable {}
extension Vector.Reversed: Sendable where Bound: Sendable {}
extension Vector.Reversed.Iterator: Sendable where Bound: Sendable {}

// MARK: - Conditional Copyable

extension Vector.Iterator: Copyable where Bound: Copyable {}
extension Vector.Reversed.Iterator: Copyable where Bound: Copyable {}
