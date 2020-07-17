//
//  EntitySystem+Tags.swift
//  EmberEngine-macOS
//
//  Created by Stephen Kac on 7/18/18.
//

import Foundation

// MARK: Tags
extension EntitySystem {
    /// Returns the count of all the tags in the system.
    public var tagCount: Int {
        return entityByTag.count
    }

    /// Returns wether or not the tag exists in the system. The tag may contain zero entities.
    public func contains(_ tag: EntityTag) -> Bool {
        return entityByTag[tag] != nil
    }

    /// Adds an entity to a Tag. Throws if the entity doesnt exist.
    public mutating func add(_ tag: EntityTag, to entity: Entity) throws {
        guard allEntities.contains(entity) else { throw Error.entityDoesNotExist(entity) }

        if entityByTag[tag] == nil {
            entityByTag[tag] = [entity]
        } else {
            entityByTag[tag]?.insert(entity)
        }
    }

    /// Removes a tag from an entity. Throws if the entity doesnt exist.
    public mutating func remove(_ tag: EntityTag, from entity: Entity) throws {
        guard allEntities.contains(entity) else { throw Error.entityDoesNotExist(entity) }

        entityByTag[tag]?.remove(entity)
    }

    /// Removes a tag from a system.
    public mutating func removeTagFromAllEntities(_ tag: EntityTag) {
        entityByTag[tag] = nil
    }

    /// Returns wether the entity contains the tag. Throws if the entity doesnt exist.
    public func does(entity: Entity, contain tag: EntityTag) throws -> Bool {
        guard allEntities.contains(entity) else { throw Error.entityDoesNotExist(entity) }

        return entityByTag[tag]?.contains(entity) ?? false
    }

    /// Returns true if the entity contains all the tags given. Throws if the entity doesnt exist.
    public func does(entity: Entity, contain tags: [EntityTag]) throws -> Bool {
        guard allEntities.contains(entity) else { throw Error.entityDoesNotExist(entity) }

        var containsAllTags = true
        for tag in tags where containsAllTags {
            containsAllTags = entityByTag[tag]?.contains(entity) ?? false
        }

        return containsAllTags
    }

    /// Gets a set of entities that contain a given tag. Returns an empty Set if there are none.
    public func getEntities(with tag: EntityTag) -> Set<Entity> {
        return entityByTag[tag] ?? Set<Entity>()
    }

    /// Gets all the tags for a given entity and throws if the entity does not exist. Mostly used for debugging.
    public func getTags(for entity: Entity) throws -> Set<EntityTag> {
        guard allEntities.contains(entity) else { throw Error.entityDoesNotExist(entity) }
        return Set(entityByTag.compactMap {
            if $0.value.contains(entity) {
                return $0.key
            }
            return nil
        })
    }

    /// Gets entities that contain all of the given tags. Returns an empty set if there are no matches.
    public func getEntities(with tags: [EntityTag]) -> Set<Entity> {

        guard let beginningTag = tags.first else { return Set<Entity>() }
        guard let entitieInBeginningTag = entityByTag[beginningTag] else { return Set<Entity>() }
        var entities = entitieInBeginningTag

        for tag in tags {
            guard let entititesWithTag = entityByTag[tag] else { continue }
            entities.formIntersection(entititesWithTag)
        }

        return entities
    }

    /// Gets entities with any of the given tags. Returns an empty set if there are none.
    public func getEntities(withAny tags: [EntityTag]) -> Set<Entity> {
        var entities = Set<Entity>()
        for tag in tags {
            guard let entititesWithTag = entityByTag[tag] else { continue }
            entities.formUnion(entititesWithTag)
        }

        return entities
    }

    /// Gets all the entities without the given tags.
    public func getEntities(without tags: [EntityTag]) -> Set<Entity> {
        var entities = allEntities

        for tag in tags {
            guard let entitiesWithTag = entityByTag[tag] else { continue }
            entities.subtract(entitiesWithTag)
        }

        return entities
    }
}
