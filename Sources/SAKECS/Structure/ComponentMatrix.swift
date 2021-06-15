//
//  ComponentMatrix.swift
//  SAKECS
//
//  Created by Stephen Kac on 1/2/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation
import SAKBase

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

	public var componentArchetype: ComponentArchetype {
		ComponentArchetype(required: Array(componentFamilyMatrixRowMap.keys))
	}

	/// The counts of the different types of Components
	public var containedComponentTypesCount: Int {
		componentFamilyMatrixRowMap.count
	}

	/// Count of colums in the matrix, as all component arrays must be equal
	public var componentColumns: Int

	/// A map of the index for a component family.
	private var componentFamilyMatrixRowMap = [ComponentFamilyID: ComponentRowIndex]()

	/// The components storage
	private var matrix = MutableArray<AnyComponentRow>()

	public init(numberOfColumns: Int) {
		componentColumns = numberOfColumns
	}

	func copyComponents(
		for sourceColumnIndex: ComponentColumnIndex,
		to destination: inout Self,
		destinationColumnIndex: ComponentColumnIndex
	) {
		for sourceRowIndex in componentFamilyMatrixRowMap.values {
			matrix[sourceRowIndex.index]
				.getAnyComponent(at: sourceColumnIndex)
				.copy(to: &destination, atIndex: destinationColumnIndex)
		}
	}

	/// Checks if the component type is contained
	/// - Parameter type: the type to check for
	public func contains<Component: EntityComponent>(rowOf type: Component.Type) -> Bool {
		contains(rowWith: Component.familyID)
	}

	/// Checks if the component type is contained
	/// - Parameter type: the type to check for
	public func contains(rowWith familyID: ComponentFamilyID) -> Bool {
		componentFamilyMatrixRowMap.keys.contains(familyID)
	}

	/// Gets the components of the given type, returns an empty array otherwise.
	/// - Parameter type: The type of components to get
	/// - Returns: An array of all the matching componenets
	public func getRow<Component: EntityComponent>(of type: Component.Type) -> ComponentRow<Component> {
		guard let componentMatrixRow = componentFamilyMatrixRowMap[Component.familyID] else {
			return []
		}

		guard let rowContainer = matrix[componentMatrixRow.index].row as? ComponentRow<Component> else {
			assertionFailure("Internal logic error, the componentFamilyMatrixRowMap does not match the matrix")
			return []
		}

		return rowContainer
	}

	/// Gets the components of the given type, returns an empty array otherwise.
	/// - Parameter type: The type of components to get
	/// - Returns: An array of all the matching componenets
	public func get<Component: EntityComponent>(
		component type: Component.Type,
		for column: ComponentColumnIndex
	) -> Component? {
		guard
			let componentMatrixRow = componentFamilyMatrixRowMap[Component.familyID],
			componentMatrixRow != .invalidIndex
		else {
			return nil
		}

		return (matrix[componentMatrixRow.index].row as? ComponentRow<Component>)?[column] ?? nil
	}

	/// Gets the component for the given type and column.
	/// Does nothing if the component type does not  already have a row.
	/// - Parameter component: The component to add
	public mutating func set<Component: EntityComponent>(component: Component, for column: ComponentColumnIndex) {

		guard let componentMatrixRow = componentFamilyMatrixRowMap[Component.familyID],
					componentMatrixRow != .invalidIndex
		else {
			return
		}

		matrix.modifying { mutableMatrix in
			component.setUnsafely(to: mutableMatrix[componentMatrixRow.index], at: column)
		}
	}

	/// Removes a component type from the matrix
	/// O(C) Time complexity wher C is the number of component types
	/// - Parameter type: The component type being removed
	public mutating func remove<Component: EntityComponent>(rowOf type: Component.Type) {
		remove(rowWith: Component.familyID)
	}

	/// Removes a component type from the matrix
	/// O(C) Time complexity wher C is the number of component types
	/// - Parameter type: The component type being removed
	public mutating func remove(rowWith familyID: ComponentFamilyID) {
		guard let componentMatrixRowToRemove = componentFamilyMatrixRowMap[familyID] else {
			// Do nothing as we do not have that componenet type
			return
		}

		for (type, row) in componentFamilyMatrixRowMap where row > componentMatrixRowToRemove {
			componentFamilyMatrixRowMap[type] = index(before: row)
		}

		matrix.remove(at: componentMatrixRowToRemove.index)
		componentFamilyMatrixRowMap.removeValue(forKey: familyID)
	}

	/// Adds a new component type to the internal storage.  O(1) Time Complexity operation.
	/// If the component type already exists it returns the same row as the original
	/// - Parameter familyID: The type of component for the array
	/// - Returns: The row for the new matrix row
	@discardableResult
	public mutating func add<Component: EntityComponent>(rowFor type: Component.Type) -> ComponentRowIndex {
		if let componentMatrixRow = componentFamilyMatrixRowMap[Component.familyID] {
			return componentMatrixRow
		}
		let componentMatrixRow = ComponentRowIndex(matrix.count)

		// Create a new component array filled with the same number of columns as the other components arrays
		let componentRow = ComponentRow<Component>(columnsCount: componentColumns)
		matrix.append(AnyComponentRow(row: componentRow))
		componentFamilyMatrixRowMap[Component.familyID] = componentMatrixRow
		return componentMatrixRow
	}
}

// MARK: - Collections

// MARK: RandomAccessCollection

extension ComponentMatrix: RandomAccessCollection {

	public subscript(rowIndex: ComponentRowIndex) -> ComponentRowProtocol {
		matrix[rowIndex.index].row
	}

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
		matrix.first
	}

	public var last: ComponentRowProtocol? {
		matrix.last
	}

	public func index(after index: ComponentRowIndex) -> ComponentRowIndex {
		ComponentRowIndex(matrix.index(after: index.index))
	}

	public func index(before index: ComponentRowIndex) -> ComponentRowIndex {
		ComponentRowIndex(matrix.index(before: index.index))
	}
}

// MARK: Index functions for ComponentColumns

public extension ComponentMatrix {

	var columnIndices: ComponentColumnIndices {
		AnyComponentRow.getIndexesForRow(ofSize: componentColumns)
	}

	/// The position of the first element in a nonempty column row,
	/// gaurenteed to be valid in all ComponentRows of the same length
	var columnStartIndex: ComponentColumnIndex {
		matrix.first?.startIndex ?? .invalid
	}

	/// The position of the last element plus one in a nonempty column row,
	/// gaurenteed to be valid in all ComponentRows of the same length
	var columnEndIndex: ComponentColumnIndex {
		matrix.first?.endIndex ?? .invalid
	}

	/// Returns the position immediately after the given index.
	/// - Parameter index: A valid index which much be greater than the start index and less than or equal to the end index
	/// - Returns: A index after the given index if there is one
	func columnIndex(after index: ComponentColumnIndex) -> ComponentColumnIndex {
		matrix.first?.index(after: index) ?? columnEndIndex
	}

	/// Returns the position immediately before the given index.
	/// - Parameter index: A valid index which much be greater than the start index and less than or equal to the end index
	/// - Returns: A index before the given index if there is one
	func columnIndex(before index: ComponentColumnIndex) -> ComponentColumnIndex {
		matrix.first?.index(before: index) ?? columnStartIndex
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

extension EntityComponent {
	func copy(to matrix: inout ComponentMatrix, atIndex: ComponentColumnIndex) {
		matrix.set(component: self, for: atIndex)
	}

	func setUnsafely<AnyMutableValueRef: MutableValueReference<AnyComponentRow>>(
		to row: AnyMutableValueRef,
		at index: ComponentColumnIndex
	) {
		row.setUnsafelyComponent(self, at: index)
	}
}
