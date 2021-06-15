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

	@inlinable
	public var columnIndices: ComponentColumnIndices {
		wrappedValue.columnIndices
	}

	@inlinable
	public var startIndex: ComponentColumnIndex {
		wrappedValue.startIndex
	}

	@inlinable
	public var endIndex: ComponentColumnIndex {
		wrappedValue.endIndex
	}

	@inlinable
	public func index(after index: ComponentColumnIndex) -> ComponentColumnIndex {
		wrappedValue.index(after: index)
	}

	@inlinable
	public func index(before index: ComponentColumnIndex) -> ComponentColumnIndex {
		wrappedValue.index(before: index)
	}

	@inlinable
	public var count: Int {
		wrappedValue.count
	}

	@inlinable
	public func getAnyComponent(at index: ComponentColumnIndex) -> EntityComponent {
		wrappedValue.getAnyComponent(at: index)
	}

	@inlinable
	public func getUnsafelyComponent<AnyComponent: EntityComponent>(
		at index: ComponentColumnIndex
	) -> AnyComponent {
		wrappedValue.getUnsafelyComponent(at: index)
	}

	@inlinable
	public func setUnsafelyComponent<AnyComponent: EntityComponent>(
		_ component: AnyComponent,
		at index: ComponentColumnIndex
	) {
		wrappedValue.setUnsafelyComponent(component, at: index)
	}
}
