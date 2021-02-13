//
//  MutableArray.swift
//  SAKECS
//
//  Created by Stephen Kac on 2/13/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

/// Acts like an array but allows structs to be mutable if declared in a variable with COW semantics.
/// It is recomended to extend the RefContainer type to conform to the protocol of the contained type for ease of use.
public struct MutableArray<Element> {

	private var internalArray: [MutableValueReference<Element>]

	public init() {
		internalArray = []
	}

	public init<S: Sequence>(_ sequence: S) where S.Element == Element {
		internalArray = sequence.map { MutableValueReference($0) }
	}
}

extension MutableArray: Collection {
	public typealias Iterator = IndexingIterator<Self>

	public typealias Element = Element

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
		get {
			internalArray[position].value
		}
		set {
			makeSureIsUniquelyReferenced(at: position)
			internalArray[position].value = newValue
		}
	}

	/// This is what makes the mutable array special. We can get a reference to the container for the element
	/// and change its contents.
	public mutating func getContainer(for index: Index) -> MutableValueReference<Element> {
		// Due to returning mutable references, we need to copy our cotents if not
		// uniquely referenced.
		makeSureIsUniquelyReferenced(at: index)
		return internalArray[index]
	}

	public func index(after index: Index) -> Int {
		internalArray.index(after: index)
	}
}

extension MutableArray: ExpressibleByArrayLiteral {
	public typealias ArrayLiteralElement = Element

	public init(arrayLiteral elements: ArrayLiteralElement...) {
		internalArray = elements.map { MutableValueReference($0) }
	}
}
extension MutableArray: BidirectionalCollection {
	public func index(before index: Int) -> Int {
		internalArray.index(before: index)
	}
}

extension MutableArray: RandomAccessCollection {}

extension MutableArray: CustomStringConvertible where Element: CustomStringConvertible {
	public var description: String {
		"[\(map(\.description).joined(separator: ", "))]"
	}
}

extension MutableArray: CustomDebugStringConvertible {
	public var debugDescription: String {
		"\(Self.self)(\(internalArray))"
	}
}

extension MutableArray: Sequence {

}

// MARK: - Private helpers
private extension MutableArray {
	/// Call this function to make sure we are uniquely referenced before making mutating changes.
	mutating func makeSureIsUniquelyReferenced(at index: Index) {
		if !isKnownUniquelyReferenced(&internalArray[index]) {
			internalArray = internalArray.map { MutableValueReference($0.value) }
		}
	}
}
