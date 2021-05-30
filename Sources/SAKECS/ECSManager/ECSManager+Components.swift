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
		componentSystem.set(component, to: entity)

		updateMaskWith(
			entity: entity,
			update: entityMasks[entity]?.components.contains(familyID) ?? false ? .modified : .added,
			familyID: familyID
		)
  }

  /// IF the component exists for the entity gets it. Otherwise returns nil.
  public func get<ComponentType: EntityComponent>(
		componentType: ComponentType.Type, for entity: Entity) -> ComponentType? {
		componentSystem.get(componentType, for: entity)
  }

  /// Removes the component from the entity and notifies those interested
  public func remove<ComponentType: EntityComponent>(componentType: ComponentType.Type, from entity: Entity) {
		guard componentSystem.contains(componentType) == true else { return }

		componentSystem.remove(componentType, from: entity)
		updateMaskWith(entity: entity, update: .removed, familyID: componentType.familyID)
  }

	public func removeComponent(
		with familyID: ComponentFamilyID,
		from entity: Entity
	) {
		guard componentSystem.containsComponent(with: familyID) else { return }

		componentSystem.removeComponent(with: familyID, from: entity)
		updateMaskWith(entity: entity, update: .removed, familyID: familyID)
	}

	func removeAllComponents(for entity: Entity) {

		entityMasks[entity]?.components.forEach {
			updateMaskWith(entity: entity, update: .removed, familyID: $0)
		}

		componentSystem.remove(entity: entity)
	}

  /// Updates an entities mask and notifies the parties interested.
	private func updateMaskWith(entity: Entity, update: MaskUpdate, familyID: ComponentFamilyID) {
		if entityMasks[entity] == nil {
			entityMasks[entity] = ContainedItems()
		}

		entityMasks[entity]?.components.insert(familyID)
		guard let mask = entityMasks[entity]
		else { os_log(.error, "Entity Mask was nil when it shouldnt have been."); return }

		let componentRequiredSystems = prioritySortedSystems.filter { $0.entityQuery.requiredComponents.contains(familyID) }
		let componentIllegalSystems = prioritySortedSystems.filter { $0.entityQuery.illegalComponents.contains(familyID) }

		switch update {
		case .added:
			for system in componentRequiredSystems where !system.entitiesMatchingQuery.contains(entity) {
				if system.entityQuery.isSatisfied(by: mask) {
					system.entitiesMatchingQuery.insert(entity)
				}
			}

			for system in componentIllegalSystems {
				system.entitiesMatchingQuery.remove(entity)
			}

			events.componentEvent.raise(ChangeEvent.set(familyID), value: entity)
		case .modified:
			events.componentEvent.raise(ChangeEvent.set(familyID), value: entity)
		case .removed:
			for system in componentRequiredSystems {
				system.entitiesMatchingQuery.remove(entity)
			}

			for system in componentIllegalSystems where !system.entitiesMatchingQuery.contains(entity) {
				if system.entityQuery.isSatisfied(by: mask) {
					system.entitiesMatchingQuery.insert(entity)
				}
			}

			events.componentEvent.raise(ChangeEvent.removed(familyID), value: entity)
		}
  }
}
