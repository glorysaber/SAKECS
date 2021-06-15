//
//  ECSManager+AnyEntityComponent.swift
//  SAKECS
//
//  Created by Stephen Kac on 6/13/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

public extension ECSManager {
	@inlinable
	func set(
		component anyComponent: AnyEntityComponent,
		to entity: Entity
	) {
		anyComponent.component.set(to: Unmanaged<ECSManager>.passUnretained(self), for: entity)
	}
}

internal extension EntityComponent {
	@usableFromInline
	func set(to ecs: Unmanaged<ECSManager>, for entity: Entity) {
		ecs.takeUnretainedValue().set(component: self, to: entity)
	}
}
