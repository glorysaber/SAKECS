//
//  ComponentRow.swift
//  SAKECS
//
//  Created by Stephen Kac on 1/3/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

/// A row of like components.
public struct ComponentRow<Component: EntityComponent> {

	/// The private component store
	fileprivate(set) var columns = [Component]()

	/// Gets or sets the given component for the index
	public subscript(column: ComponentColumnIndex) -> Component {
		get {
			columns[column.index]
		}
		set {
			columns[column.index] = newValue
		}
	}

	public init() {}

	/// Adds the given number of columns
	public mutating func growColumns(by toGrowBy: Int) -> ComponentColumnIndices {
		// Will be a valid index once we grow
		let beginningEndIndex = endIndex
		columns.append(contentsOf: Array(repeating: Component(), count: toGrowBy))
		return beginningEndIndex..<endIndex
	}

	public var columnIndices: ComponentColumnIndices {
		isEmpty ? .emptyInvalid : startIndex..<endIndex
	}
}

extension ComponentRow: RandomAccessCollection {

	public typealias Element = Component

	public var startIndex: ComponentColumnIndex {
		ComponentColumnIndex(columns.startIndex)
	}

	public var endIndex: ComponentColumnIndex {
		ComponentColumnIndex(columns.endIndex)
	}

	public var count: Int {
		columns.count
	}

	public var first: Component? {
		columns.first
	}

	public var last: Component? {
		columns.last
	}

	public func index(after index: ComponentColumnIndex) -> ComponentColumnIndex {
		ComponentColumnIndex(columns.index(after: index.index))
	}

	public func index(before index: ComponentColumnIndex) -> ComponentColumnIndex {
		ComponentColumnIndex(columns.index(before: index.index))
	}

	public __consuming func makeIterator() -> IndexingIterator<[Component]> {
		columns.makeIterator()
	}
}

extension ComponentRow: CustomStringConvertible, CustomDebugStringConvertible {
	public var description: String {
		"The row consists of \(count) elements of component type \(Element.self)"
	}

	public var debugDescription: String {
		"""
		count: \(count)
		Element: \(Element.self)
		InternalArray: \(columns)
		"""
	}
}

extension ComponentRow: ExpressibleByArrayLiteral {
	public typealias ArrayLiteralElement = Component

	public init(arrayLiteral elements: Component...) {
		columns = elements
	}
}

extension ComponentRow: Codable where Component: Codable {}

extension ComponentRow: Equatable where Component: Equatable {}

extension ComponentRow: RangeReplaceableCollection {}
