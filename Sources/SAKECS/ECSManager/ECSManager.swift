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
	public internal(set) var entityMasks = [Entity: ContainedItems]()

	/// Holds all the types of components and manages what entity they are set too.
	internal var componentSystem: WorldEntityComponentService

	/// The ECS's current time.
	public internal(set) var systemTime: Double

	internal init(
		entitySystem: EntitySystem = EntitySystem(),
		prioritySortedSystems: [EntityComponentSystem] = [EntityComponentSystem](),
		active: Bool = true,
		entityMasks: [Entity: ContainedItems] = [Entity: ContainedItems](),
		componentSystem: WorldEntityComponentService,
		systemTime: Double = 0.0
	) {
		self.entitySystem = entitySystem
		self.prioritySortedSystems = prioritySortedSystems.sorted { $0.priority >= $1.priority }
		self.active = active
		self.entityMasks = entityMasks
		self.componentSystem = componentSystem
		self.systemTime = systemTime
	}

  /// Properly deinitializes all its variables
  deinit {
    for system in prioritySortedSystems {
      system.ecs = nil
    }
  }

	enum MaskUpdate {
		case removed
		case added
		case modified
	}
}
