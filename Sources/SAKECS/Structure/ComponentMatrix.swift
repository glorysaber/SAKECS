//
//  ComponentMatrix.swift
//  SAKECS
//
//  Created by Stephen Kac on 1/2/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

// MARK: - RowContainerProtocol

// Used to allow for homogeneous storage of reference wrapping containers
private protocol RowContainerProtocol: AnyObject {
	/// Gets the count of the columns of the stored row
	var count: Int { get }

	/// Grows the columns of the stored row
	/// - Parameter toGrowBy: The number of columns to grow by
	func growColumns(by toGrowBy: Int) -> ComponentColumnIndices

	/// The contained element
	var containedElement: ComponentRowProtocol { get }
}

// MARK: - ComponentRowIndex

/// The row for a component array  in the component matrix
public struct ComponentRowIndex: Comparable {
	public static func < (lhs: ComponentRowIndex, rhs: ComponentRowIndex) -> Bool {
		lhs.index < rhs.index
	}

	/// Indexes are only valid when there collection is non empty,
	/// so checking against this value is not enough to know if an index is invalid.
	public static let invalidIndex = ComponentRowIndex(-1)

	fileprivate let index: Int

	fileprivate init(_ index: Int) {
		self.index = index
	}
}

// MARK: - ComponentMatrix

/// The storage representation of the components which belong to entities
public struct ComponentMatrix {

	enum Error: Swift.Error {
		/// Component Types cannot be added twice
		case componentAlreadyExists
	}

	/// A contianer for each row to allow mutability
	private class RowContainer<Component: EntityComponent>: RowContainerProtocol {
		var containedElement: ComponentRowProtocol {
			row
		}

		var count: Int {
			row.count
		}

		/// Grows the columns by the given integer and then returns an empty or non empty collection.
		/// - Parameter toGrowBy: The number to grow this rows columns by
		/// - Returns: The additional new indices
		func growColumns(by toGrowBy: Int) -> ComponentColumnIndices {
			row.growColumns(by: toGrowBy)
		}

		var row: ComponentRow<Component>

		init(_ row: ComponentRow<Component>) {
			self.row = row
		}
	}

	/// The counts of the different types of Components
	public var containedComponentTypesCount: Int {
		componentFamilyMatrixRowMap.count
	}

	/// Count of colums in the matrix, as all component arrays must be equal
	public var componentColumns: Int {
		matrix.first?.count ?? 0
	}

	/// A map of the index for a component family.
	private var componentFamilyMatrixRowMap = [ComponentFamilyID: ComponentRowIndex]()

	/// The components storage
	private var matrix = [RowContainerProtocol]()

	public init() {}

	/// Checks if the component type is contained
	/// - Parameter type: the type to check for
	public func contains<Component: EntityComponent>(_ type: Component.Type) -> Bool {
		componentFamilyMatrixRowMap.keys.contains(type.familyID)
	}

	/// Gets the components of the given type, returns an empty array otherwise.
	/// - Parameter type: The type of components to get
	/// - Returns: An array of all the matching componenets
	public func get<Component: EntityComponent>(_ type: Component.Type) -> ComponentRow<Component> {
		guard let componentMatrixRow = componentFamilyMatrixRowMap[Component.familyID] else {
			return []
		}

		guard let rowContainer = matrix[componentMatrixRow.index] as? RowContainer<Component> else {
			assertionFailure("Internal logic error, the componentFamilyMatrixRowMap does not match the matrix")
			return []
		}

		return rowContainer.row
	}

	/// Gets the components of the given type, returns an empty array otherwise.
	/// - Parameter type: The type of components to get
	/// - Returns: An array of all the matching componenets
	public func get<Component: EntityComponent>(_ type: Component.Type, for column: ComponentColumnIndex) -> Component? {
		guard let componentMatrixRow = componentFamilyMatrixRowMap[Component.familyID] else {
			return nil
		}

		return (matrix[componentMatrixRow.index] as? RowContainer<Component>)?.row[column] ?? nil
	}

	/// Gets the component for the given type and column.
	/// Does nothing if the component type does not  already have a row.
	/// - Parameter component: The component to add
	public mutating func set<Component: EntityComponent>(_ component: Component, for column: ComponentColumnIndex) {
		guard let componentMatrixRow = componentFamilyMatrixRowMap[Component.familyID] else {
			return
		}

		guard let rowContainer = matrix[componentMatrixRow.index] as? RowContainer<Component>  else {
			assertionFailure("Encountered nexpected type at row: \(componentMatrixRow.index) ")
			return
		}
		rowContainer.row[column] = component
	}

	public mutating func addColumns(_ columnsToGrowBy: Int) -> ComponentColumnIndices {

		var iterator = matrix.makeIterator()

		guard columnsToGrowBy > 0, let firstComponentRow = iterator.next() else { return .empty }

		let firstIndices = firstComponentRow.growColumns(by: columnsToGrowBy)

		guard firstIndices != .empty else {
			return .empty
		}

		while let componentRow = iterator.next(), componentRow.count < firstComponentRow.count {
			let growBy = Swift.min(firstComponentRow.count - componentRow.count, columnsToGrowBy)
			guard componentRow.growColumns(by: growBy) != .empty else {
				assertionFailure("Failed to grow columns.")
				return .empty
			}
		}

		assert(matrix.map({ $0.count == firstComponentRow.count})
						.reduce(true, { $0 && $1 }) == true,
					 "Component rows are not equal length")

		return firstIndices
	}

	/// Removes a component type from the matrix
	/// O(C) Time complexity wher C is the number of component types
	/// - Parameter type: The component type being removed
	public mutating func remove<Component: EntityComponent>(_ type: Component.Type) {
		guard let componentMatrixRowToRemove = componentFamilyMatrixRowMap[Component.familyID] else {
			// Do nothing as we do not have that componenet type
			return
		}

		for (type, row) in componentFamilyMatrixRowMap where row > componentMatrixRowToRemove {
			componentFamilyMatrixRowMap[type] = index(before: row)
		}

		matrix.remove(at: componentMatrixRowToRemove.index)
		componentFamilyMatrixRowMap.removeValue(forKey: Component.familyID)
	}

	/// Adds a new component type to the internal storage.  O(1) Time Complexity operation.
	/// If the component type already exists it returns the same row as the original
	/// - Parameter familyID: The type of component for the array
	/// - Returns: The row for the new matrix row
	@discardableResult
	public mutating func add<Component: EntityComponent>(_ type: Component.Type) -> ComponentRowIndex {
		if let componentMatrixRow =  componentFamilyMatrixRowMap[Component.familyID] {
			return componentMatrixRow
		}
		let componentMatrixRow = ComponentRowIndex(matrix.count)

		// Create a new component array filled with the same number of columns as the other components arrays
		var componentRow = ComponentRow<Component>()
		_ = componentRow.growColumns(by: matrix.first?.count ?? 0)
		matrix.append(RowContainer(componentRow))
		componentFamilyMatrixRowMap[Component.familyID] = componentMatrixRow
		return componentMatrixRow
	}
}

// MARK: - Collections

// MARK: RandomAccessCollection

extension ComponentMatrix: RandomAccessCollection {

	public subscript(rowIndex: ComponentRowIndex) -> ComponentRowProtocol {
			matrix[rowIndex.index].containedElement
	}

	public typealias Element = ComponentRowProtocol

	public var startIndex: ComponentRowIndex {
		ComponentRowIndex(matrix.startIndex)
	}

	public var endIndex: ComponentRowIndex {
		ComponentRowIndex(matrix.endIndex)
	}

	public var count: Int {
		containedComponentTypesCount
	}

	public var first: ComponentRowProtocol? {
		matrix.first?.containedElement
	}

	public var last: ComponentRowProtocol? {
		matrix.last?.containedElement
	}

	public func index(after index: ComponentRowIndex) -> ComponentRowIndex {
		ComponentRowIndex(matrix.index(after: index.index))
	}

	public func index(before index: ComponentRowIndex) -> ComponentRowIndex {
		ComponentRowIndex(matrix.index(before: index.index))
	}

	public struct Iterator: IteratorProtocol {
		public typealias Element = ComponentRowProtocol

		private let matrix: [RowContainerProtocol]
		private var position = 0

		public mutating func next() -> ComponentRowProtocol? {
			defer {
				position += 1
			}
			guard position < matrix.count else {
				return nil
			}

			return matrix[position].containedElement
		}

		fileprivate init(matrix: [RowContainerProtocol]) {
			self.matrix = matrix
		}

	}

	public __consuming func makeIterator() -> Iterator {
		Iterator(matrix: matrix)
	}
}

// MARK: Index functions for ComponentColumns

public extension ComponentMatrix {

	var columnIndices: ComponentColumnIndices {
		matrix.first?.containedElement.columnIndices ?? .empty
	}

	/// The position of the first element in a nonempty column row,
	/// gaurenteed to be valid in all ComponentRows of the same length
	var columnStartIndex: ComponentColumnIndex {
		matrix.first?.containedElement.startIndex ?? .invalid
	}

	/// The position of the last element plus one in a nonempty column row,
	/// gaurenteed to be valid in all ComponentRows of the same length
	var columnEndIndex: ComponentColumnIndex {
		matrix.first?.containedElement.endIndex ?? .invalid
	}

	/// Returns the position immediately after the given index.
	/// - Parameter index: A valid index which much be greater than the start index and less than or equal to the end index
	/// - Returns: A index after the given index if there is one
	func columnIndex(after index: ComponentColumnIndex) -> ComponentColumnIndex {
		matrix.first?.containedElement.index(after: index) ?? columnEndIndex
	}

	/// Returns the position immediately before the given index.
	/// - Parameter index: A valid index which much be greater than the start index and less than or equal to the end index
	/// - Returns: A index before the given index if there is one
	func columnIndex(before index: ComponentColumnIndex) -> ComponentColumnIndex {
		matrix.first?.containedElement.index(before: index) ?? columnStartIndex
	}
}

// MARK: - description

extension ComponentMatrix: CustomStringConvertible, CustomDebugStringConvertible {
	public var description: String {
		"The matrix consists of \(count) types of components and \(componentColumns) columns"
	}

	public var debugDescription: String {
		"""
		typeCount: \(count)
		componentCount: \(componentColumns)
		matrix: \(matrix)
		"""
	}
}
