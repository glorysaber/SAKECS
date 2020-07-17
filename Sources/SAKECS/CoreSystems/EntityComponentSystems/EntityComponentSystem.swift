//
//  EntityComponentSystem.swift
//  EmberEngine
//
//  Created by Stephen Kac on 7/8/18.
//

import Foundation
import SAKBase

/// Acts upon entities and their components
public protocol EntityComponentSystem: class {

  /// Everytime a change happens to an entity, if it matches this query it will be inserted into entitiesMatchingQuery
  var entityQuery: EntityQuery { get set }

  /// Everytime a change happens to an entity, if it matches entityQuery it will be inserted into entitiesMatchingQuery
  var entitiesMatchingQuery: Set<Entity> { get set }

  /// The manager of this system
  var ecs: ECSManager? { get set }

  /// The prioriry which decides when this system will be called in relation to other systems.
  var priority: Int { get }

  /// Updates the system with the change in time since last update.
  @discardableResult
  func update(withDelta systemTimeDelta: Double) -> Bool

  /// Called in reverse order of update in terms of system order.
  func updateFinalize() -> Bool
}

extension EntityComponentSystem {
  // Sets priority to be
  public var priority: Int {
    return 0
  }

  /// Default update method
  public func update(withDelta systemTimeDelta: Double) -> Bool {
    return true
  }

  public func updateFinalize() -> Bool {
    return true
  }
}
