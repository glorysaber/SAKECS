//
//  ECSManager + Tags.swift
//  EmberEngine
//
//  Created by Stephen Kac on 7/22/18.
//

import Foundation
import os.log

extension ECSManager: WorldTagService {
  /// Adds an entity to a Tag
  public func add<Raw: RawRepresentable>(tag: Raw, to entity: Entity) where Raw.RawValue == EntityTag {
    add(tag: tag.rawValue, to: entity)
  }

  /// Removes a tag from an entity.
  public func remove<Raw: RawRepresentable>(tag: Raw, from entity: Entity) where Raw.RawValue == EntityTag {
    remove(tag: tag.rawValue, from: entity)
  }

  /// Adds an entity to a Tag. Throws if the entity doesnt exist.
  public func add(tag: EntityTag, to entity: Entity) {
    _ = try? entitySystem.add(tag, to: entity)
    updateMaskWith(entity: entity, removed: false, tag: tag)
  }

  /// Removes a tag from an entity. Throws if the entity doesnt exist.
  public func remove(tag: EntityTag, from entity: Entity) {
    _ = try? entitySystem.remove(tag, from: entity)
    updateMaskWith(entity: entity, removed: true, tag: tag)
  }

  /// Updates an entities mask based on tag
  private func updateMaskWith(entity: Entity, removed: Bool, tag: EntityTag) {
    if entityMasks[entity] == nil {
      entityMasks[entity] = ContainedItems()
    }

    entityMasks[entity]?.tags.insert(tag)
    if entityMasks[entity] == nil {
      entityMasks[entity] = ContainedItems()
    }

    entityMasks[entity]?.tags.insert(tag)
    guard let mask = entityMasks[entity]
		else {
			os_log(.error, "Entity Mask was nil when it shouldnt have been.")
			return
		}

    let tagRequiredSystems = prioritySortedSystems.filter { $0.entityQuery.requiredTags.contains(tag) }
    let tagIllegalSystems = prioritySortedSystems.filter { $0.entityQuery.illegalTags.contains(tag) }

    if removed {

      for system in tagRequiredSystems {
        system.entitiesMatchingQuery.remove(entity)
      }

      for system in tagIllegalSystems where !system.entitiesMatchingQuery.contains(entity) {
        if system.entityQuery.isSatisfied(by: mask) {
          system.entitiesMatchingQuery.insert(entity)
        }
      }

      events.tagEvent.raise(ChangeEvent.removed(tag), value: entity)
    } else {
      for system in tagRequiredSystems where !system.entitiesMatchingQuery.contains(entity) {
        if system.entityQuery.isSatisfied(by: mask) {
          system.entitiesMatchingQuery.insert(entity)
        }
      }

      for system in tagIllegalSystems {
        system.entitiesMatchingQuery.remove(entity)
      }
      events.tagEvent.raise(ChangeEvent.set(tag), value: entity)
    }
  }
}
