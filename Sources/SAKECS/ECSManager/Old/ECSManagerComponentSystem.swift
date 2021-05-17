//
//  ECSManagerComponentSystems.swift
//  SAKECS
//
//  Created by Stephen Kac on 4/24/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

class ECSManagerComponentSystem: WorldEntityComponentService {

	public var componentCount: Int {
		return componentSystems.values.reduce(0) {
			return $0 + $1.componentCount
		}
	}

	private var componentSystems = [ComponentFamilyID: ComponentStorage]()

	func containsComponent(
		with familyID: ComponentFamilyID
	) -> Bool {
		componentSystems[familyID] != nil
	}

	func set<ComponentType: EntityComponent>(
		_ component: ComponentType,
		to entity: Entity
	) {
		if componentSystems[component.familyID] == nil {
			let componentSystem = ComponentSystem<ComponentType>()
			componentSystem.set(component, to: entity)
			componentSystems[component.familyID] = componentSystem
		} else {
			guard let componentSystem = componentSystems[component.familyID] as? ComponentSystem<ComponentType> else { return }
			componentSystem.set(component, to: entity)
		}
	}

	func get<ComponentType: EntityComponent>(
		_ componentType: ComponentType.Type,
		for entity: Entity
	) -> ComponentType? {
		let familyID = componentType.familyID
		guard let componentSystem = componentSystems[familyID] as? ComponentSystem<ComponentType> else { return nil }

		return componentSystem.getComponent(for: entity)
	}

	public func removeComponent(
		with familyID: ComponentFamilyID,
		from entity: Entity
	) {
		componentSystems[familyID]?.removeComponent(from: entity)
	}

	func remove(entity: Entity) {
		componentSystems.forEach { $0.value.removeComponent(from: entity) }
	}
}
