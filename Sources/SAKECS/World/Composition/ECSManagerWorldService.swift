//
//  WorldServiceAdapterECSManager.swift
//  SAKECS
//
//  Created by Stephen Kac on 2/20/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

struct ECSManagerWorldService {
	let manager = ECSManagerComposer().compose_v0_0_1()
}

extension ECSManagerWorldService: WorldEntityComponentService {
	var componentCount: Int {
		manager.componentCount
	}

	func containsComponent(
		with familID: ComponentFamilyID
	) -> Bool {
		manager.componentSystem.containsComponent(with: familID)
	}

	func set<ComponentType>(_ component: ComponentType, to entity: Entity) where ComponentType: EntityComponent {
		manager.set(component: component, to: entity)
	}

	func get<ComponentType>(
		_ componentType: ComponentType.Type,
		for entity: Entity
	) -> ComponentType? where ComponentType: EntityComponent {
		manager.get(componentType: componentType, for: entity)
	}

	func removeComponent(with familyID: ComponentFamilyID, from entity: Entity) {
		manager.removeComponent(with: familyID, from: entity)
	}

	func remove(entity: Entity) {
		manager.destroy(entity: entity)
	}
}

extension ECSManagerWorldService: WorldSystemService {
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

extension ECSManagerWorldService: WorldTagService {
	func contains<Raw>(tag: Raw) -> Bool  where Raw: RawRepresentable, Raw.RawValue == EntityTag {
		manager.entitySystem.contains(tag.rawValue)
	}

	func does<Raw>(entity: Entity, contain tag: Raw) -> Bool where Raw: RawRepresentable, Raw.RawValue == EntityTag {
		manager.entitySystem.entityByTag[tag.rawValue]?.contains(entity) ?? false
	}

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

extension ECSManagerWorldService: WorldEntityService {
	var entityCount: Int {
		manager.entitySystem.allEntities.count
	}

	func contains(entity: Entity) -> Bool {
		manager.entitySystem.contains(entity)
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
