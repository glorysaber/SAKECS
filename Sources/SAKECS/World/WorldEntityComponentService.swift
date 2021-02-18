//
//  WorldEntityComponentService.swift
//  SAKECS
//
//  Created by Stephen Kac on 2/18/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

public protocol WorldEntityComponentService {

	/// Sets a component to an entity and notifies any interested parties.
	func set<ComponentType: EntityComponent>(component: ComponentType, to entity: Entity)

	/// IF the component exists for the entity gets it. Otherwise returns nil.
	func get<ComponentType: EntityComponent>(
		componentType: ComponentType.Type, for entity: Entity) -> ComponentType?

	/// Removes the component from the entity and notifies those interested
	func remove<ComponentType: EntityComponent>(componentType: ComponentType.Type, from entity: Entity)
}
