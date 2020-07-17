//
//  ECSManager.swift
//  EmberEngine
//
//  Created by Stephen Kac on 7/8/18.
//

import Foundation
import os.log
import SAKBase

/*
 The ECSManager is the head of operations for an ECS.
	It allows for Components and Tags to be safely adhered to to an Entity.
	It also mantains systems and the current systemTime.
 */
public class ECSManager {

  /// The system that handles Tags and entities
  public internal(set) var entitySystem = EntitySystem()

  /// A list of priority sorted systems that get run at every increaseSystemTime(by time: Double)
  internal var prioritySortedSystems = [EntityComponentSystem]() {
    didSet {
      prioritySortedSystems.sort { $0.priority >= $1.priority }
    }
  }

  public var active = true

  /// Processes all the ECS events
  public let events = CentralEventSystem()

  /// All entities with contained items
  internal var entityMasks = [Entity: ContainedItems]()

  /// Holds all the types of components and manages what entity they are set too.
  internal var componentSystems = [ComponentFamilyID: ComponentStorage]()

  /// The ECS's current time.
  public internal(set) var systemTime = 0.0

  /// Initializes a default instance of the ECS
  public init() {}

  /// Properly deinitializes all its variables
  deinit {
    for system in prioritySortedSystems {
      system.ecs = nil
    }
  }

}
