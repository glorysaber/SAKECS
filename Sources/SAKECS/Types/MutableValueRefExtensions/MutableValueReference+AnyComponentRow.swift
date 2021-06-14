//
//  MutableValueReference+AnyComponentRow.swift
//  SAKECS
//
//  Created by Stephen Kac on 6/11/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation
import SAKBase

extension MutableValueReference: ComponentRowProtocol where Element: ComponentRowProtocol {

	public var columnIndices: ComponentColumnIndices {
		wrappedValue.columnIndices
	}

	public var startIndex: ComponentColumnIndex {
		wrappedValue.startIndex
	}

	public var endIndex: ComponentColumnIndex {
		wrappedValue.endIndex
	}

	public func index(after index: ComponentColumnIndex) -> ComponentColumnIndex {
		wrappedValue.index(after: index)
	}

	public func index(before index: ComponentColumnIndex) -> ComponentColumnIndex {
		wrappedValue.index(before: index)
	}

	public var count: Int {
		wrappedValue.count
	}

	public func getAnyComponent(at index: ComponentColumnIndex) -> EntityComponent {
		wrappedValue.getAnyComponent(at: index)
	}

	public func getUnsafelyComponent<AnyComponent: EntityComponent>(
		at index: ComponentColumnIndex
	) -> AnyComponent {
		wrappedValue.getUnsafelyComponent(at: index)
	}

	public func setUnsafelyComponent<AnyComponent: EntityComponent>(
		_ component: AnyComponent,
		at index: ComponentColumnIndex
	) {
		wrappedValue.setUnsafelyComponent(component, at: index)
	}

	public func growColumns(by toGrowBy: Int) -> ComponentColumnIndices {
		wrappedValue.growColumns(by: toGrowBy)
	}
}
