//
//  ContainerArray.swift
//  SAKECS
//
//  Created by Stephen Kac on 2/14/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

public protocol ArrayElementContainer: AnyObject {
	associatedtype Element

	var value: Element { get }

	/// Make a deep copy
	var deepCopy: Self { get }
}

protocol ElementInitializable {
	associatedtype Element

	init(_: Element)
}

extension MutableValueReference: ArrayElementContainer {
	public var deepCopy: MutableValueReference<Element> {
		MutableValueReference(value)
	}
}

/// Acts like an array but allows structs to be mutable if declared in a variable with COW semantics.
/// It is recomended to extend the RefContainer type to conform to the protocol of the contained type for ease of use.
public struct ContainerArray<Container: ArrayElementContainer> {

	private var internalArray: [Container]

	public init() {
		internalArray = []
	}

	public init<S: Sequence>(_ sequence: S) where S.Element == Container {
		internalArray = Array(sequence)
	}
}

// MARK: - Element
// MARK: Collection
extension ContainerArray: Collection {
	public typealias Iterator = IndexingIterator<Self>

	public typealias Element = Container.Element

	public typealias Index = Int

	public var isEmpty: Bool {
		internalArray.isEmpty
	}

	public var count: Int {
		internalArray.count
	}

	public var first: Element? {
		internalArray.first?.value
	}

	public var startIndex: Index {
		internalArray.startIndex
	}

	public var endIndex: Index {
		internalArray.endIndex
	}

	public subscript(_ position: Index) -> Element {
			internalArray[position].value
	}

	public func index(after index: Index) -> Int {
		internalArray.index(after: index)
	}
}

// MARK: - Container methods
extension ContainerArray {

	/// This is what makes the mutable array special. We can get a reference to the container for the element
	/// and change its contents.
	public mutating func getContainer(for index: Index) -> Container {
		// Due to returning mutable references, we need to copy our cotents if not
		// uniquely referenced.
		makeSureIsUniquelyReferenced(at: index)
		return internalArray[index]
	}

	public mutating func firstContainer(where predicate: (Container) throws -> Bool) rethrows -> Container? {
		makeSureIsUniquelyReferenced()
		return try internalArray.first(where: predicate)
	}

	public mutating func forEachContainer(_ body: (Container) throws -> Void) rethrows {
		makeSureIsUniquelyReferenced()
		try internalArray.forEach(body)
	}

	public mutating func append(_ container: Container) {
		internalArray.append(container)
	}

}

extension ContainerArray: ExpressibleByArrayLiteral {
	public typealias ArrayLiteralElement = Container

	public init(arrayLiteral elements: ArrayLiteralElement...) {
		internalArray = Array(elements)
	}
}
extension ContainerArray: BidirectionalCollection {
	public func index(before index: Int) -> Int {
		internalArray.index(before: index)
	}
}

extension ContainerArray: RandomAccessCollection {}

extension ContainerArray: CustomStringConvertible where Element: CustomStringConvertible {
	public var description: String {
		"[\(map(\.description).joined(separator: ", "))]"
	}
}

extension ContainerArray: CustomDebugStringConvertible {
	public var debugDescription: String {
		"\(Self.self)(\(internalArray))"
	}
}

extension ContainerArray: Sequence {

}

// MARK: - Private helpers
private extension ContainerArray {
	/// Call this function to make sure we are uniquely referenced before making mutating changes.
	mutating func makeSureIsUniquelyReferenced(at index: Index = 0) {
		guard isEmpty == false else { return }

		if !isKnownUniquelyReferenced(&internalArray[index]) {
			internalArray = internalArray.map { $0.deepCopy }
		}
	}
}
