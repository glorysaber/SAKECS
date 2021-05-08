//
//  ECSManager + Systems.swift
//  EmberEngine
//
//  Created by Stephen Kac on 7/22/18.
//

import Foundation

extension ECSManager: WorldSystemService {

	/// The count of systems
	public var systemCount: Int {
		prioritySortedSystems.count
	}

  /// Updates all systems with no increase in system time
  public func tick() {
    increaseSystemTime(by: 0.00)
  }

  /// Updates all systems with an increase of 1 in system time
  public func tock() {
    increaseSystemTime(by: 1.00)
  }

  /// Updates all systems and increases the system time
  public func increaseSystemTime(by time: Double) {
    guard active && OperationQueue.current == OperationQueue.main else { return }

    systemTime += time

    for system in prioritySortedSystems where system.ecs === self {
      _ = system.update(withDelta: time)
    }

    for system in prioritySortedSystems.reversed() {
      _ = system.updateFinalize()
    }
  }

  /// Adds a system to the ECS to be ran at every system time increase
  public func add(system: EntityComponentSystem) {
    OperationQueue.main.addOperation { [weak self, system] in
      let systemType = type(of: system)
      guard let self = self,
						(!self.prioritySortedSystems.contains { type(of: $0) == type(of: systemType) }) else { return }
      system.ecs = self
      self.prioritySortedSystems.append(system)

      self.updateMask(for: system)
    }

  }

  /// removes a system
  public func remove(system: EntityComponentSystem.Type) {
    OperationQueue.main.addOperation { [weak self] in
      guard let self = self else { return }
      self.prioritySortedSystems.removeAll {
        type(of: $0) == system
      }
    }
  }

  /// gets a system of a type
  public func getSystems<SystemType: EntityComponentSystem>(ofType: SystemType.Type) -> [SystemType] {
    return prioritySortedSystems.filter { type(of: $0) == ofType } as? [SystemType] ?? [SystemType]()
  }

  /// updates a mask for a system
  private func updateMask(for system: EntityComponentSystem) {
    for entityMask in entityMasks {
      if system.entityQuery.isSatisfied(by: entityMask.value) {
        system.entitiesMatchingQuery.insert(entityMask.key)
      }
    }
  }
}
