//
//  MetaEntity + Tags.swift
//  EmberEngine
//
//  Created by Stephen Kac on 7/25/18.
//

import Foundation

// MARK: tags

extension MetaEntity {
  /// Count of tags on entity, returns 0 if entity is invalid.
  public func tagCount() -> Int {
    return ecs?.entitySystem.tagCount ?? 0
  }
  
  /// Returns a set of tags assigned to the entity. Returns an empty set if the entity is invalid.
  public func tags() -> Set<Tag> {
    guard let (entity, ecs) = getValidated() else { return Set<Tag>() }
    do {
      return try ecs.entitySystem.getTags(for: entity)
    } catch let error {
      lastError = error
      return Set<Tag>()
    }
    
  }
  
  /// Returns a bool indicating if the tag is contained, if Entity is Invalid false is returned by default.
  public func contains(tag: Tag) -> Bool {
    guard let (entity, ecs) = getValidated() else { return false }
    do {
      return (try ecs.entitySystem.does(entity: entity, contain: tag))
    } catch let error {
      lastError = error
      return false
    }
  }
  
  /// Adds the tag to the entity if it still exists
  public func add<Raw: RawRepresentable>(tag: Raw) where Raw.RawValue == String {
    guard let (entity, ecs) = getValidated() else { return }
    ecs.add(tag: tag, to: entity)
  }
  
  /// Removes the tag from the entity if the entity still exists
  public func remove<Raw: RawRepresentable>(tag: Raw) where Raw.RawValue == String {
    guard let (entity, ecs) = getValidated() else { return }
    ecs.remove(tag: tag, from: entity)
  }
  
  /// Returns false if invalid
  public func contains(_ tags: [Tag]) -> Bool {
    guard let (entity, ecs) = getValidated() else { return false }
    do {
      return try ecs.entitySystem.does(entity: entity, contain: tags)
    } catch let error {
      lastError = error
      return false
    }
  }
}
