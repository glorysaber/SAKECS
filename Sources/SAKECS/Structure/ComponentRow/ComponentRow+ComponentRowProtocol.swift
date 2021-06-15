//
//  ComponentRow+ComponentRowProtocol.swift
//  SAKECS
//
//  Created by Stephen Kac on 6/11/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

extension ComponentRow: ComponentRowProtocol {
	@inlinable
	public func getUnsafelyComponent<AnyComponent: EntityComponent>(at index: ComponentColumnIndex) -> AnyComponent {
		guard let component = self[index] as? AnyComponent else {
			fatalError("Non matching component types.")
		}

		return component
	}

	@inlinable
	public mutating func setUnsafelyComponent<AnyComponent: EntityComponent>(
		_ anyComponent: AnyComponent, at index: ComponentColumnIndex
	) {
		guard let component = anyComponent as? Component else { fatalError("Non matching component types.") }

		self[index] = component
	}

	@inlinable
	public func getAnyComponent(at index: ComponentColumnIndex) -> EntityComponent {
		self[index]
	}

	@inlinable
	public mutating func setUnsafelyAnyComponent(
		_ anyComponent: EntityComponent,
		at index: ComponentColumnIndex
	) {
		guard let component = anyComponent as? Component else {
			preconditionFailure("anyComponent was of unexpectd type \(type(of: anyComponent)) when it expectd \(Component.self)")
		}
		self[index] = component
	}
}
