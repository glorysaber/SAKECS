//
//  EntitySystem+Entity.swift
//  EmberEngine-macOS
//
//  Created by Stephen Kac on 7/18/18.
//

import Foundation

//TODO: Possibly move more checking to MetaEntity which should be safe. EntitySystem Functions do not have to check.
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
    public mutating func newEntity() throws -> Entity  {
        guard allEntities.count != Entity.max else { throw Error.entitySystemIsFull }
        repeat { lastID = 1 &+ lastID } while allEntities.contains(lastID)
        
        allEntities.insert(lastID)
        
        return lastID
    }
    
    //  /// Registers the entity in the component system. Throws if the entity already exists
    //  private func register(entity: Entity) throws {
    //    guard !allEntities.contains(entity) else {
    //      throw Error.entityAlreadyExists
    //    }
    //
    //    allEntities.insert(entity)
    //  }
    
    /// Removes an entity immediately from the EntitySystem
    public mutating func destroy(_ entity: Entity) {
        allEntities.remove(entity)
    }
    
    /// Removes an entity immediately from the EntitySystem
    public mutating func destroy<EntitiesType: Sequence>(_ entities: EntitiesType) where EntitiesType.Element == Entity {
        allEntities.subtract(entities)
        
        for (key, _) in entityByTag {
            for entity in entities {
                entityByTag[key]?.remove(entity)
            }
        }
    }
    
    //      /// Returns an MetaEntity matching an identifier
    //      public func getMetaEntity(for entity: Entity) throws -> MetaEntity {
    //          guard allEntities.contains(entity) else { throw Error.entityDoesNotExist(entity) }
    //          return MetaEntity(entity: entity, entitySystem: self)
    //      }
}
