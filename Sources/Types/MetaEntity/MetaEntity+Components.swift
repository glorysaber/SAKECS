//
//  MetaEntity+Components.swift
//  EmberEngine
//
//  Created by Stephen Kac on 7/25/18.
//

import Foundation

// MARK: Component functions
extension MetaEntity {
  
  /// Gets a component of the given type from the entity
  public func get<ComponentType: EntityComponent>(componentType: ComponentType.Type) -> ComponentType? {
    guard let (entity, ecs) = getValidated() else { return nil }
    
    return ecs.get(componentType: componentType.self, for: entity)
  }
  
  
  
  /// removes a component if MetaEntity is valid and the component exists.
  public func remove<ComponentType: EntityComponent>(componentType: ComponentType.Type)  {
    guard let (entity, ecs) = getValidated() else { return }
    ecs.remove(componentType: componentType, from: entity)
  }
  
  /// Sets a component onto the entity if it is valid
  public func set<ComponentType: EntityComponent>(component: ComponentType) {
    guard let (entity, ecs) = getValidated() else { return }
    ecs.set(component: component, to: entity)
  }
}
