//
//  AnyComponentRow.swift
//  SAKECS
//
//  Created by Stephen Kac on 6/12/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

struct AnyComponentRow {
	@usableFromInline
	var row: ComponentRowProtocol

	@inlinable
	static func getIndexesForRow(ofSize size: Int) -> ComponentColumnIndices {
		guard size > 0 else { return .emptyInvalid }
		return ComponentColumnIndex(0)..<ComponentColumnIndex(size)
	}
}

extension AnyComponentRow: ComponentRowProtocol {
	@inlinable var count: Int {
		row.count
	}

	@inlinable var columnIndices: ComponentColumnIndices {
		row.columnIndices
	}

	@inlinable var startIndex: ComponentColumnIndex {
		row.startIndex
	}

	@inlinable var endIndex: ComponentColumnIndex {
		row.endIndex
	}

	@inlinable
	func index(after index: ComponentColumnIndex) -> ComponentColumnIndex {
		row.index(after: index)
	}

	@inlinable
	func index(before index: ComponentColumnIndex) -> ComponentColumnIndex {
		row.index(before: index)
	}

	@inlinable
	func getAnyComponent(at index: ComponentColumnIndex) -> EntityComponent {
		row.getAnyComponent(at: index)
	}

	@inlinable
	func getUnsafelyComponent<AnyComponent: EntityComponent>(
		at index: ComponentColumnIndex
	) -> AnyComponent {
		row.getUnsafelyComponent(at: index)
	}

	@inlinable
	mutating func setUnsafelyComponent<AnyComponent: EntityComponent>(
		_ component: AnyComponent,
		at index: ComponentColumnIndex
	) {
		row.setUnsafelyComponent(component, at: index)
	}
}
