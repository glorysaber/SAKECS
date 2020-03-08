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
  
  @inline(__always)
  /// A convienince function for when you want 2 components all typed checked or nothing at all.
  public func get<Component1: EntityComponent, Component2: EntityComponent>(components component1: Component1.Type, _ component2: Component2.Type) -> (Component1, Component2)? {
    guard let component1 = get(componentType: component1) else { return nil }
    guard let component2 = get(componentType: component2) else { return nil }
    return (component1, component2)
  }
  
  @inline(__always)
  /// A convienince function for when you want 3 components all typed checked or nothing at all.
  public func get<Component1: EntityComponent, Component2: EntityComponent, Component3: EntityComponent>(components component1: Component1.Type, _ component2: Component2.Type, _ component3: Component3.Type) -> (Component1, Component2, Component3)? {
    guard let components = get(components: component1, component2) else { return nil }
    guard let component3 = get(componentType: component3) else { return nil }
    return (components.0, components.1, component3)
  }
  
  @inline(__always)
  /// A convienince function for when you want 4 components all typed checked or nothing at all.
  public func get<Component1: EntityComponent, Component2: EntityComponent, Component3: EntityComponent, Component4: EntityComponent>(components component1: Component1.Type, _ component2: Component2.Type, _ component3: Component3.Type, _ component4: Component4.Type) -> (Component1, Component2, Component3, Component4)? {
    guard let components = get(components: component1, component2) else { return nil }
    guard let components2 = get(components: component3, component4) else { return nil }
    return (components.0, components.1, components2.0, components2.1)
  }
  
}
