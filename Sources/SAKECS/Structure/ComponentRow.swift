//
//  ComponentRow.swift
//  SAKECS
//
//  Created by Stephen Kac on 1/3/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

/// The Index type for a column in a component row
public struct ComponentColumnIndex: Index {
	public let index: Int

	public init(index: Int) {
		self.index = index
	}
}
extension ComponentColumnIndex: Strideable {
	public func distance(to other: ComponentColumnIndex) -> Int {
		other.index - index
	}

	public func advanced(by advances: Int) -> ComponentColumnIndex {
		self + advances
	}

	public typealias Stride = Int

	public static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.index < rhs.index
	}

}

/// A type erasing protocol for component rows, component rows need to be casted for any type safe methods.
public protocol ComponentRowProtocol {

	/// The number of components in the row.
	var count: Int { get }

	/// The position of the first element in a nonempty row.
	var startIndex: ComponentColumnIndex { get }

	/// The  “past the end” position—that is, the position one greater than the last valid subscript argument.
	var endIndex: ComponentColumnIndex { get }

	/// Returns the position immediately after the given index.
	func index(after index: ComponentColumnIndex) -> ComponentColumnIndex

	/// Returns the position immediately before the given index.
	func index(before index: ComponentColumnIndex) -> ComponentColumnIndex

	/// Adds the given number of columns using the default required initializer as the default values
	mutating func growColumns(by toGrowBy: Int)
}

/// A row of like components.
public struct ComponentRow<Component: EntityComponent>: ComponentRowProtocol {

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
	public mutating func growColumns(by toGrowBy: Int) {
		columns.append(contentsOf: Array(repeating: Component(), count: toGrowBy))
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
