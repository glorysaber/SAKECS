//
//  MetaEntity.swift
//  EmberEngine-macOS
//
//  Created by Stephen Kac on 6/26/18.
//

import Foundation

/// A fake entity that provides extra safety checks and easier use of the ECS for the client
public final class MetaEntity {

  /// Checks if the entity and system is still valid for the entity
  public var isValid: Bool {
    guard getValidated() != nil else { return false }
    return true
  }

  /// May be a MetaEntity.Error or a EntitySystem.Error
  public var lastError: Swift.Error?

  /// Errors for MetaEntity
  public enum Error: Swift.Error {
    /// Cannot find the enity system and so the Meta enity is no longer valid
    case entitySystemDoesNotExist

    /// After a few attempts failed to register the entity in the entitySystem
    case couldNotRegisterInSystem

    /// Given if the entity does not exist in the system it was associated with.
    case entityHasBeenDestroyed

    /// Meta Entit is invalid as both EntitSystem and Entity do not exists
    case invalid

    /// Internal error
    case internalError

  }

  /// The entity the MetaEntity represents
  public private(set) var entity: Entity? {
    didSet {
      if entity == nil {
        ecs = nil
      }
    }
  }

  /// The entitySystem the entity lives in
  public private(set) weak var ecs: ECSManager? {
    didSet {
      if ecs == nil {
        entity = nil
      }
    }
  }

  /// Creates a MetaEntity from an entity and checks if it exists within the system.
	/// Warning: An entity may exist in two seperate systems
  public init(entity: Entity, ecs: ECSManager) {
    self.entity = entity
    self.ecs = ecs
    guard ecs.entitySystem.contains(entity) else { lastError = Error.entityHasBeenDestroyed; return }
  }

  /// The safe way to create a new Entity within a MetaEntity
  public init(ecs: ECSManager) {
    self.ecs = ecs
    guard let entity = ecs.createEntity() else {
      lastError = Error.entityHasBeenDestroyed
      return
    }
    self.entity = entity
  }
}

// MARK: Hashable
extension MetaEntity: Hashable {
  public static func == (lhs: MetaEntity, rhs: MetaEntity) -> Bool {
    return lhs.entity == rhs.entity && lhs.ecs === rhs.ecs
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(entity.hashValue)
  }
}

// MARK: Entity functions
extension MetaEntity {
  ///Sets entity to nil and removes itself from the component system
  public func destroy() {
    guard let entity = entity else { return }
    ecs?.destroy(entity: entity)
    self.entity = nil
  }

  /// Makes the MetaEntity invalid
  public func invalidate() {
    entity = nil
    ecs = nil
  }

  /// Gets a validated tuple of the properties entity and entitySytems
  internal func getValidated() -> (Entity, ECSManager)? {
    guard let entitySystem = ecs else {
      defer {
        entity = nil
      }
      lastError = throwError()
      return nil
    }
    guard let entity = entity else {
      defer {
        self.ecs = nil
      }
      lastError = throwError()
      return nil
    }

    return (entity, entitySystem)
  }

  internal func throwError() -> Error {
    if ecs == nil && entity == nil {
      return Error.invalid
    } else if ecs == nil {
      return Error.entitySystemDoesNotExist
    } else if entity == nil {
      return Error.entityHasBeenDestroyed
    } else {
      return Error.internalError
    }
  }

}
