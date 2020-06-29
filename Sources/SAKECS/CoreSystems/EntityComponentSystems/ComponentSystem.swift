//
//  ComponentSystem.swift
//  EmberEngine-macOS
//
//  Created by Stephen Kac on 7/21/18.
//

import Foundation

//internal struct ComponentSystemTypeID: Hashable {
//  let id: ObjectIdentifier
//}

/// Basic functions needed when
internal protocol ComponentStorage {
  var componentCount: Int { get }
  func removeComponent(from entity: Entity)
}

/// Holds all the components of a single type
internal class ComponentSystem<Component: EntityComponent>: ComponentStorage {
  
  var componentCount: Int {
    return componentMap.count
  }
  
  var componentMap = Dictionary<Entity, Component>()
  
  /// Adds or replaces a component on an entity
  func set(_ component: Component, to entity: Entity) {
    componentMap[entity] = component
  }
  
  /// gets a component pointer for an entity
  func getComponent(for entity: Entity) -> Component? {
    guard componentMap[entity] != nil else { return nil }
    return componentMap[entity]!
  }
  
  /// Removes the componen from the entity
  func removeComponent(from entity: Entity) {
    componentMap[entity] = nil
  }

  /// Gets the family ID of the component that this system stores
  internal var componentFamilyID: ComponentFamilyID = {
    return ComponentFamilyID(componentType: Component.self)
  }()
  
//  internal static var typeID: ComponentSystemTypeID = {
//    return ComponentSystemTypeID(id: ObjectIdentifier(self).hashValue)
//  }()
}
