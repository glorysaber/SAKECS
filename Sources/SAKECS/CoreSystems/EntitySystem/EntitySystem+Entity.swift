//
//  EntitySystem+Entity.swift
//  EmberEngine-macOS
//
//  Created by Stephen Kac on 7/18/18.
//

import Foundation

// MARK: Entity Functions
extension EntitySystem {
    /// Performs a Set calculation to find if an entity is contained
    public func contains(_ entity: Entity) -> Bool {
        return allEntities.contains(entity)
    }

    /// Performs a Set calculation to find if all given entities are contained
    public func containsAll(_ entities: Set<Entity>) -> Bool {
        return entities.isSubset(of: allEntities)
    }

    /// Gets a EntitySystem specific unique ID and registers it to the system
    public mutating func newEntity() throws -> Entity {
        guard allEntities.count != Entity.max else { throw Error.entitySystemIsFull }
        repeat { lastID = 1 &+ lastID } while allEntities.contains(lastID)

        allEntities.insert(lastID)

        return lastID
    }

    /// Removes an entity immediately from the EntitySystem
    public mutating func destroy(_ entity: Entity) {
        allEntities.remove(entity)
    }

    /// Removes an entity immediately from the EntitySystem
    public mutating func destroy<EntitiesType: Sequence>(
			_ entities: EntitiesType) where EntitiesType.Element == Entity {
        allEntities.subtract(entities)

        for (key, _) in entityByTag {
            for entity in entities {
                entityByTag[key]?.remove(entity)
            }
        }
    }

}
