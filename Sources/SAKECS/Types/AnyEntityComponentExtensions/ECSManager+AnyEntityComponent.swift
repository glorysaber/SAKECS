//
//  ECSManager+AnyEntityComponent.swift
//  SAKECS
//
//  Created by Stephen Kac on 6/13/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

public extension ECSManager {
	func set(
		component anyComponent: AnyEntityComponent,
		to entity: Entity
	) {
		anyComponent.component.set(to: self, for: entity)
	}
}

private extension EntityComponent {
	func set(to ecs: ECSManager, for entity: Entity) {
		ecs.set(component: self, to: entity)
	}
}
