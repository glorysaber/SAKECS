//
//  EntitySystem + RawRepresentableTags.swift
//  EmberEngine
//
//  Created by Stephen Kac on 7/15/18.
//

import Foundation

/*
 Encourages the use of enums for tags.
 */

// MARK: Tags
extension EntitySystem {

  public func contains<Raw: RawRepresentable>(_ tag: Raw) -> Bool  where Raw.RawValue == String {
    return self.contains(tag.rawValue)
  }

  /// Returns wether the entity contains the tag. Throws if the entity doesnt exist.
  public func does<Raw: RawRepresentable>(entity: Entity, contain tag: Raw) throws -> Bool
	where Raw.RawValue == String {
    return try does(entity: entity, contain: tag.rawValue)
  }

  /// Returns true if the entity contains all the tags given. Throws if the entity doesnt exist.
  public func does<Raw: RawRepresentable>(entity: Entity, contain tags: [Raw]) throws -> Bool
	where Raw.RawValue == String {
    return try self.does(entity: entity, contain: tags.map { $0.rawValue })
  }

  /// Gets a set of entities that contain a given tag. Returns an empty Set if there are none.
  public func getEntities<Raw: RawRepresentable>(with tag: Raw) -> Set<Entity> where Raw.RawValue == String {
    return getEntities(with: tag.rawValue)
  }

  /// Gets entities that contain all of the given tags. Returns an empty set if there are no matches.
  public func getEntities<Raw: RawRepresentable>(with tags: [Raw]) -> Set<Entity> where Raw.RawValue == String {
    return getEntities(with: tags.map { $0.rawValue })
  }

  /// Gets entities with any of the given tags. Returns an empty set if there are none.
  public func getEntities<Raw: RawRepresentable>(withAny tags: [Raw]) -> Set<Entity> where Raw.RawValue == String {
    return getEntities(withAny: tags.map { $0.rawValue })
  }

  /// Gets all the entities without the given tags.
  public func getEntities<Raw: RawRepresentable>(without tags: [Raw]) -> Set<Entity> where Raw.RawValue == String {
    return getEntities(without: tags.map { $0.rawValue })
  }

}
