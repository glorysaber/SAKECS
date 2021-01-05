//
//  ECSManager + Components.swift
//  EmberEngine
//
//  Created by Stephen Kac on 7/22/18.
//

import Foundation
import os.log

extension ECSManager {

  /// Sets a component to an entity and notifies any interested parties.
  public func set<ComponentType: EntityComponent>(component: ComponentType, to entity: Entity) {
    guard entitySystem.contains(entity) else { return }
    let familyID = component.familyID
    if componentSystems[familyID] == nil {
      let componentSystem = ComponentSystem<ComponentType>()
      componentSystem.set(component, to: entity)
      componentSystems[familyID] = componentSystem
    } else {
      guard let componentSystem = componentSystems[familyID] as? ComponentSystem<ComponentType> else { return }
      componentSystem.set(component, to: entity)
    }

    updateMaskWith(entity: entity, removed: false, familyID: ComponentType.familyID)
  }

  /// IF the component exists for the entity gets it. Otherwise returns nil.
  public func get<ComponentType: EntityComponent>(
		componentType: ComponentType.Type, for entity: Entity) -> ComponentType? {
    let familyID = ComponentFamilyID(componentType: componentType)
    guard let componentSystem = componentSystems[familyID] as? ComponentSystem<ComponentType> else { return nil }

    return componentSystem.getComponent(for: entity)
  }

  /// Removes the component from the entity and notifies those interested
  internal func remove(familyID: ComponentFamilyID, from entity: Entity) {
    componentSystems[familyID]?.removeComponent(from: entity)

    updateMaskWith(entity: entity, removed: true, familyID: familyID)
  }

  /// Removes the component from the entity and notifies those interested
  public func remove<ComponentType: EntityComponent>(componentType: ComponentType.Type, from entity: Entity) {
    let familyID = ComponentFamilyID(componentType: componentType)
    guard componentSystems[familyID] != nil else { return }

    remove(familyID: familyID, from: entity)
  }

  /// Updates an entities mask and notifies the parties interested.
  private func updateMaskWith(entity: Entity, removed: Bool, familyID: ComponentFamilyID) {
    if entityMasks[entity] == nil {
      entityMasks[entity] = ContainedItems()
    }

    entityMasks[entity]?.components.insert(familyID)
    guard let mask = entityMasks[entity]
      else { os_log(.error, "Entity Mask was nil when it shouldnt have been."); return }

    let componentRequiredSystems = prioritySortedSystems.filter { $0.entityQuery.requiredComponents.contains(familyID) }
    let componentIllegalSystems = prioritySortedSystems.filter { $0.entityQuery.illegalComponents.contains(familyID) }

    if removed {
      for system in componentRequiredSystems {
        system.entitiesMatchingQuery.remove(entity)
      }

      for system in componentIllegalSystems where !system.entitiesMatchingQuery.contains(entity) {
        if system.entityQuery.isSatisfied(by: mask) {
          system.entitiesMatchingQuery.insert(entity)
        }
      }

      events.componentEvent.raise(ChangeEvent.removed(familyID), value: entity)
    } else {
      for system in componentRequiredSystems where !system.entitiesMatchingQuery.contains(entity) {
        if system.entityQuery.isSatisfied(by: mask) {
          system.entitiesMatchingQuery.insert(entity)
        }
      }

      for system in componentIllegalSystems {
        system.entitiesMatchingQuery.remove(entity)
      }

      events.componentEvent.raise(ChangeEvent.set(familyID), value: entity)
    }
  }
}
