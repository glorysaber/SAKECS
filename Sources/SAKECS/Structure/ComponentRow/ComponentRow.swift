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
	@usableFromInline fileprivate(set) var columns: ContiguousArray<Component>

	/// Gets or sets the given component for the index
	@inlinable
	public subscript(column: ComponentColumnIndex) -> Component {
		get {
			columns[column.index]
		}
		set {
			columns[column.index] = newValue
		}
	}

	@inlinable
	public init(columnsCount: Int) {
		self.columns = ContiguousArray<Component>(repeating: Component(), count: columnsCount)
	}

	@inlinable
	public var columnIndices: ComponentColumnIndices {
		isEmpty ? .emptyInvalid : startIndex..<endIndex
	}
}

extension ComponentRow: RandomAccessCollection {

	public typealias Element = Component

	@inlinable
	public var startIndex: ComponentColumnIndex {
		ComponentColumnIndex(columns.startIndex)
	}

	@inlinable
	public var endIndex: ComponentColumnIndex {
		ComponentColumnIndex(columns.endIndex)
	}

	@inlinable
	public var count: Int {
		columns.count
	}

	@inlinable
	public var first: Component? {
		columns.first
	}

	@inlinable
	public var last: Component? {
		columns.last
	}

	@inlinable
	public func index(after index: ComponentColumnIndex) -> ComponentColumnIndex {
		ComponentColumnIndex(columns.index(after: index.index))
	}

	@inlinable
	public func index(before index: ComponentColumnIndex) -> ComponentColumnIndex {
		ComponentColumnIndex(columns.index(before: index.index))
	}

	@inlinable
	public __consuming func makeIterator() -> IndexingIterator<ContiguousArray<Component>> {
		columns.makeIterator()
	}
}

extension ComponentRow: CustomStringConvertible, CustomDebugStringConvertible {
	@inlinable public var description: String {
		"The row consists of \(count) elements of component type \(Element.self)"
	}

	@inlinable public var debugDescription: String {
		"""
		count: \(count)
		Element: \(Element.self)
		InternalArray: \(columns)
		"""
	}
}

extension ComponentRow: ExpressibleByArrayLiteral {
	public typealias ArrayLiteralElement = Component

	@inlinable
	public init(arrayLiteral elements: Component...) {
		columns = ContiguousArray<Component>(elements)
	}
}

extension ComponentRow: Codable where Component: Codable {}

extension ComponentRow: Equatable where Component: Equatable {}
