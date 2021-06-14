//
//  AnyComponentRow.swift
//  SAKECS
//
//  Created by Stephen Kac on 6/12/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

struct AnyComponentRow {
	var row: ComponentRowProtocol
}

extension AnyComponentRow: ComponentRowProtocol {
	var count: Int {
		row.count
	}

	var columnIndices: ComponentColumnIndices {
		row.columnIndices
	}

	var startIndex: ComponentColumnIndex {
		row.startIndex
	}

	var endIndex: ComponentColumnIndex {
		row.endIndex
	}

	func index(after index: ComponentColumnIndex) -> ComponentColumnIndex {
		row.index(after: index)
	}

	func index(before index: ComponentColumnIndex) -> ComponentColumnIndex {
		row.index(before: index)
	}

	mutating func growColumns(by toGrowBy: Int) -> ComponentColumnIndices {
		row.growColumns(by: toGrowBy)
	}

	func getAnyComponent(at index: ComponentColumnIndex) -> EntityComponent {
		row.getAnyComponent(at: index)
	}

	func getUnsafelyComponent<AnyComponent: EntityComponent>(
		at index: ComponentColumnIndex
	) -> AnyComponent {
		row.getUnsafelyComponent(at: index)
	}

	mutating func setUnsafelyComponent<AnyComponent: EntityComponent>(
		_ component: AnyComponent,
		at index: ComponentColumnIndex
	) {
		row.setUnsafelyComponent(component, at: index)
	}
}
