//
//  WorldServiceAdapterECSManager.swift
//  SAKECS
//
//  Created by Stephen Kac on 2/20/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

struct WorldServiceAdapterECSManager {
	let manager = ECSManager()
}

extension WorldServiceAdapterECSManager: WorldSystemService {
	var systemCount: Int {
		manager.systemCount
	}

	func tick() {
		manager.tick()
	}

	func tock() {
		manager.tock()
	}

	func increaseSystemTime(by time: Double) {
		manager.increaseSystemTime(by: time)
	}

	func add(system: EntityComponentSystem) {
		manager.add(system: system)
	}

	func remove(system: EntityComponentSystem.Type) {
		manager.remove(system: system)
	}

	func getSystems<SystemType>(
		ofType systemType: SystemType.Type
	) -> [SystemType] where SystemType: EntityComponentSystem {
		manager.getSystems(ofType: systemType)
	}
}

extension WorldServiceAdapterECSManager: WorldTagService {
	func add<Raw>(tag: Raw, to entity: Entity) where Raw: RawRepresentable, Raw.RawValue == EntityTag {
		manager.add(tag: tag, to: entity)
	}

	func remove<Raw>(tag: Raw, from entity: Entity) where Raw: RawRepresentable, Raw.RawValue == EntityTag {
		manager.remove(tag: tag, from: entity)
	}

	func add(tag: EntityTag, to entity: Entity) {
		manager.add(tag: tag, to: entity)
	}

	func remove(tag: EntityTag, from entity: Entity) {
		manager.remove(tag: tag, from: entity)
	}
}

extension WorldServiceAdapterECSManager: WorldEntityService {
	var componentCount: Int {
		manager.componentCount
	}

	func destroy(entity: Entity) {
		manager.destroy(entity: entity)
	}

	func destroy(entities: [Entity]) {
		manager.destroy(entities: entities)
	}

	func createEntity() -> Entity? {
		manager.createEntity()
	}

	func createEntities(_ amount: Int) -> [Entity] {
		manager.createEntities(amount)
	}
}

extension WorldServiceAdapterECSManager: WorldEntityComponentService {
	func set<ComponentType>(
		component: ComponentType,
		to entity: Entity
	) where ComponentType: EntityComponent {
		manager.set(component: component, to: entity)
	}

	func get<ComponentType>(
		componentType: ComponentType.Type,
		for entity: Entity
	) -> ComponentType? where ComponentType: EntityComponent {
		manager.get(componentType: componentType, for: entity)
	}

	func remove<ComponentType>(
		componentType: ComponentType.Type,
		from entity: Entity
	) where ComponentType: EntityComponent {
		manager.remove(componentType: componentType, from: entity)
	}

}
