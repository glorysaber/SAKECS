//
//  EntitySystem.swift
//  EmberEngine
//
//  Created by Stephen Kac on 6/25/18.
//

import Foundation

// MARK: - EntitySystem
// TODO: Conform to codable
public struct EntitySystem {

  public var systemManager: ECSManager?
    
    /// Last ID used for an entity
  internal var lastID: Entity = 0
  
  /// Stores all valid entitys
  public internal(set) var allEntities = Set<Entity>()
  
  /// Entity stored by Tag
  internal var entityByTag = Dictionary<Tag, Set<Entity>>()
  
  
  //////////////////////////////////////////////////////////////////////////
  // MARK: Internal Types
  
  /// General errors for the EntitySystem
  public enum Error: Swift.Error {
    case entityDoesNotExist(Entity)
    case internalError
    case entityAlreadyExists
    case entitySystemIsFull
  }

  public init() {}
}


