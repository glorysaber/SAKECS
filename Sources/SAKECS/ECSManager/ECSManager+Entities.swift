//
//  ECSManager + Entities.swift
//  EmberEngine-macOS
//
//  Created by Stephen Kac on 7/23/18.
//

import Foundation

extension ECSManager {

  /// removes an entity from all systems
	public func destroy(entity: Entity) {
    entitySystem.destroy(entity)

    let dead = MetaEntity(entity: entity, ecs: self)

		removeAllComponents(for: entity)

    for tag in dead.itemsContained.tags {
      remove(tag: tag, from: entity)
    }

		updateMaskWith(entity: entity, update: .removed)
  }

  /// Removes a group of entities from all entities
	public func destroy(entities: [Entity]) {

    for entity in entities {
      destroy(entity: entity)
    }
  }

  /// Creates an entity, returns nil if unsuccessfully created
	public func createEntity() -> Entity? {
    guard let entity = try? entitySystem.newEntity() else { return nil }

		updateMaskWith(entity: entity, update: .added)

    return entity
  }

  /// Returns a gauranteed amound of entities, else nil and removes the entities from the system if any were created
	public func createEntities(_ amount: Int) -> [Entity] {
    var entities = [Entity]()

    for _ in 0..<amount {
      guard let entity = try? entitySystem.newEntity() else {
        for entity in entities {
          destroy(entity: entity)
        }
        return []
      }

      entities.append(entity)
			updateMaskWith(entity: entity, update: .added)
    }

    return entities
  }

  /// Updates all an entities mask
	private func updateMaskWith(entity: Entity, update: MaskUpdate) {
		switch update {
		case .added:
			for system in prioritySortedSystems where system.entityQuery.isSatisfied(by: ContainedItems()) {
				system.entitiesMatchingQuery.insert(entity)
			}
			events.entityEvent.raise(ChangeType.set, value: entity)
		case .removed:
			for system in prioritySortedSystems {
				system.entitiesMatchingQuery.remove(entity)
			}
			events.entityEvent.raise(ChangeType.removed, value: entity)
		case .modified:
			events.entityEvent.raise(ChangeType.set, value: entity)
		}
  }
}
