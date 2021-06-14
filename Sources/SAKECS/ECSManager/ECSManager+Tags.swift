//
//  ECSManager + Tags.swift
//  EmberEngine
//
//  Created by Stephen Kac on 7/22/18.
//

import Foundation
import os.log

extension ECSManager {
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
		updateMaskWith(entity: entity, change: .added, tag: tag)
  }

  /// Removes a tag from an entity. Throws if the entity doesnt exist.
  public func remove(tag: EntityTag, from entity: Entity) {
    _ = try? entitySystem.remove(tag, from: entity)
		updateMaskWith(entity: entity, change: .removed, tag: tag)
  }

  /// Updates an entities mask based on tag
  private func updateMaskWith(entity: Entity, change: MaskUpdate, tag: EntityTag) {
		var mask = entityMasks[entity] ?? {
			let mask = ContainedItems()
			entityMasks[entity] = mask
			return mask
		}()

    let tagRequiredSystems = prioritySortedSystems.filter { $0.entityQuery.requiredTags.contains(tag) }
    let tagIllegalSystems = prioritySortedSystems.filter { $0.entityQuery.illegalTags.contains(tag) }

		switch change {
		case .removed:
			mask.tags.remove(tag)
			for system in tagRequiredSystems {
				system.entitiesMatchingQuery.remove(entity)
			}

			for system in tagIllegalSystems where
				!system.entitiesMatchingQuery.contains(entity) &&
				system.entityQuery.isSatisfied(by: mask) {
					system.entitiesMatchingQuery.insert(entity)
			}

			events.tagEvent.raise(ChangeEvent.removed(tag), value: entity)
		case .added:
			mask.tags.insert(tag)
			for system in tagRequiredSystems where
				!system.entitiesMatchingQuery.contains(entity) &&
				system.entityQuery.isSatisfied(by: mask) {
					system.entitiesMatchingQuery.insert(entity)
			}

			for system in tagIllegalSystems {
				system.entitiesMatchingQuery.remove(entity)
			}
			events.tagEvent.raise(ChangeEvent.added(tag), value: entity)
		case .modified:
			events.tagEvent.raise(ChangeEvent.assigned(tag), value: entity)
		}

		entityMasks[entity] = mask
  }
}
