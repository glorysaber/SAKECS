//
//  ECSManager + Components.swift
//  EmberEngine
//
//  Created by Stephen Kac on 7/22/18.
//

import Foundation
import os.log

extension ECSManager {

	/// Gets the total component count of all componentTypes
	public var componentCount: Int {
		componentSystem.componentCount
	}

  /// Sets a component to an entity and notifies any interested parties.
  public func set<ComponentType: EntityComponent>(component: ComponentType, to entity: Entity) {
    guard entitySystem.contains(entity) else { return }
    let familyID = component.familyID
		componentSystem.set(component: component, to: entity)

		updateMask(
			withEntity: entity,
			update: entityMasks[entity]?.components.contains(familyID) ?? false ? .modified : .added,
			familyID: familyID
		)
  }

  /// IF the component exists for the entity gets it. Otherwise returns nil.
  public func get<ComponentType: EntityComponent>(
		component: ComponentType.Type, for entity: Entity) -> ComponentType? {
		componentSystem.get(component: component, for: entity)
  }

  /// Removes the component from the entity and notifies those interested
  public func remove<ComponentType: EntityComponent>(component: ComponentType.Type, from entity: Entity) {
		guard componentSystem.contains(component) == true else { return }

		componentSystem.remove(component, from: entity)
		updateMask(withEntity: entity, update: .removed, familyID: component.familyID)
  }

	public func remove(
		componentWith familyID: ComponentFamilyID,
		from entity: Entity
	) {
		guard componentSystem.contains(componentWith: familyID) else { return }

		componentSystem.remove(componentWith: familyID, from: entity)
		updateMask(withEntity: entity, update: .removed, familyID: familyID)
	}

	func removeAllComponents(for entity: Entity) {

		entityMasks[entity]?.components.forEach {
			updateMask(withEntity: entity, update: .removed, familyID: $0)
		}

		componentSystem.remove(entity: entity)
	}

  /// Updates an entities mask and notifies the parties interested.
	private func updateMask(withEntity: Entity, update: MaskUpdate, familyID: ComponentFamilyID) {

		var mask = entityMasks[withEntity] ?? {
			let mask = ContainedItems()
			entityMasks[withEntity] = mask
			return mask
		}()

		let componentRequiredSystems = prioritySortedSystems
			.filter { $0.entityQuery.requiredComponents.contains(familyID) }
		let componentIllegalSystems = prioritySortedSystems
			.filter { $0.entityQuery.illegalComponents.contains(familyID) }

		switch update {
		case .added:
			mask.addComponent(with: familyID)
			for system in componentRequiredSystems where
				!system.entitiesMatchingQuery.contains(withEntity) &&
				system.entityQuery.isSatisfied(by: mask) {
				system.entitiesMatchingQuery.insert(withEntity)
			}

			for system in componentIllegalSystems {
				system.entitiesMatchingQuery.remove(withEntity)
			}

			events.componentEvent.raise(ChangeEvent.added(familyID), value: withEntity)
		case .modified:
			events.componentEvent.raise(ChangeEvent.assigned(familyID), value: withEntity)
		case .removed:
			mask.removeComponent(with: familyID)
			for system in componentRequiredSystems {
				system.entitiesMatchingQuery.remove(withEntity)
			}

			for system in componentIllegalSystems where
				!system.entitiesMatchingQuery.contains(withEntity) &&
				system.entityQuery.isSatisfied(by: mask) {
				system.entitiesMatchingQuery.insert(withEntity)
			}

			events.componentEvent.raise(ChangeEvent.removed(familyID), value: withEntity)
		}

		entityMasks[withEntity] = mask
  }
}
