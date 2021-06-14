//
//  AnyComponentRow.swift
//  SAKECS
//
//  Created by Stephen Kac on 6/11/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

/// A type erasing protocol for component rows, component rows need to be casted for any type safe methods.
public protocol ComponentRowProtocol {

	/// The number of components in the row.
	var count: Int { get }

	/// The typeerased indices of the Component Row without a copy or reference to the structure where
	/// all indices are valid
	/// for any given ComponentRowProtocol of the same length or greater
	var columnIndices: ComponentColumnIndices { get }

	/// The position of the first element in a nonempty row.
	var startIndex: ComponentColumnIndex { get }

	/// The  “past the end” position—that is, the position one greater than the last valid subscript argument.
	var endIndex: ComponentColumnIndex { get }

	/// Returns the position immediately after the given index.
	func index(after index: ComponentColumnIndex) -> ComponentColumnIndex

	/// Returns the position immediately before the given index.
	func index(before index: ComponentColumnIndex) -> ComponentColumnIndex

	/// Adds the given number of columns using the default required initializer as the default values
	mutating func growColumns(by toGrowBy: Int) -> ComponentColumnIndices

	/// - Returns: a component with an unknown concrete type
	func getAnyComponent(at index: ComponentColumnIndex) -> EntityComponent

	func getUnsafelyComponent<AnyComponent: EntityComponent>(at index: ComponentColumnIndex) -> AnyComponent

	/// Uses the type information to quickly crash if the types do not match, quickly sets the component otherwise
	/// - _:   The component to set
	mutating func setUnsafelyComponent<AnyComponent: EntityComponent>(
		_ component: AnyComponent,
		at index: ComponentColumnIndex
	)
}
