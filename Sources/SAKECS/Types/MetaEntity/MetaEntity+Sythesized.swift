//
//  MetaEntity + Sythesized.swift
//  EmberEngine
//
//  Created by Stephen Kac on 7/26/18.
//

import Foundation

extension MetaEntity {

  /// Gets the entities mask from the entity system.
  public var itemsContained: ContainedItems {
    guard let entity = entity else { return ContainedItems() }
    return ecs?.entityMasks[entity] ?? ContainedItems()
  }

  @inlinable
  /// A convienince function for when you want 2 components all typed checked or nothing at all.
  public func get<Component1: EntityComponent, Component2: EntityComponent>(
		components component1: Component1.Type,
		_ component2: Component2.Type) -> (Component1, Component2)? {
    guard let component1 = get(componentType: component1) else { return nil }
    guard let component2 = get(componentType: component2) else { return nil }
    return (component1, component2)
  }
}
