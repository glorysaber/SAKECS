//
//  EntitySystem+Components.swift
//  EmberEngine-macOS
//
//  Created by Stephen Kac on 7/18/18.
//

import Foundation

//MARK: Single Component Functions
extension EntitySystem {
    
    public var componentTypeCount: Int {
        return componentsByEntityByType.count
    }
    
    /// Gets a component of a given type for an entity. Throws if the entity doesnt exist or when the component is not found.
    public func get<ComponentType: Component>(_ componentType: ComponentType.Type, for entity: Entity) throws -> ComponentType {
        guard allEntities.contains(entity) else { throw Error.entityDoesNotExist(entity)}
        
        guard let store: ComponentByEntity = componentsByEntityByType[ObjectIdentifier(componentType)] else {
            throw Error.componentNotFound(entity: entity, componentType: componentType)
        }
        
        guard let component = store[entity] else {
            throw Error.componentNotFound(entity: entity, componentType: componentType)
        }
        
        guard let result = component as? ComponentType else {
            throw Error.internalError
        }
        
        return result
    }
    
    /// Gets all the components of a given type in the system for all entities. Throws if an entity doesnt exist and can cause a failure of the system if theres an internal error.
    public func getEntities<ComponentType: EntityComponent>(with componentType: ComponentType.Type) -> Set<Entity> {
        
        
        guard let componentsByEntity = componentsByEntityByType[ObjectIdentifier(componentType)] else {
            return Set<Entity>()
        }
        
        guard let components = componentsByEntity as? [Entity : ComponentType] else {
            //TODO: COnvert to a failState that is recoverable
            fatalError("Unexpected component(s) withing an dictionary which should have been of type Dictionary<Entity, \(ComponentType.self)")
        }
        
        return Set<Entity>(components.keys)
    }
    
    /// Gets all components for a given entity. Throws EntitySyste,.Error if the entity does not exist. Runs O(x)
    public func getAllComponents(for entity: Entity) throws -> ComponentsByType {
        guard allEntities.contains(entity) else { throw Error.entityDoesNotExist(entity)}
        var components = ComponentsByType()
        for (componentTypeHash , componentByEntity) in componentsByEntityByType {
            if let component = componentByEntity[entity] {
                components[componentTypeHash] = component
            }
        }
        return components
    }
    
    /// Adds a given component to an entity. Throws an error if the entity does not exist. If you want to replace a component type for an entity call set<ComponentType: EntitySystem.Component>(ComponentType, to: Entity) throws instead as adding a component that already exists does nothing.
    public func add(_ component: Component, to entity: Entity) throws {
        try add([component], to: entity)
    }
    
    /// Removes an entity from the component. Throws if the entity does not exist.
    public func remove<ComponentType: EntitySystem.Component>(_ componentType: ComponentType.Type, from entity: Entity) throws  {
        guard allEntities.contains(entity) else { throw Error.entityDoesNotExist(entity) }
        
        remove([componentType], from: [entity])
    }
    
    /// Updates or adds a value for a component, throws if the entity does not exist
    public func set(_ component: Component, to entity: Entity) throws {
        try set([component], to: entity)
    }
}




// MARK: Arrays of Components
extension EntitySystem {
    
    //  ///
    //  public func getEntitiesAndComponents<ComponentType: Component>(with componentType: ComponentType.Type) -> [(Entity, ComponentType)] {
    //    guard let componentsByEntity = componentsByEntityByType[ComponentTypeHash(type: componentType)] as? [Entity : ComponentType] else { return [(Entity, ComponentType)]() }
    //
    //    return componentsByEntity.compactMap () { return ($0, $1)}
    //  }
    
    ///
    public func getEntities(with componentTypes: [Component.Type]) -> Set<Entity> {
        guard componentTypes.count > 0 else { return Set<Entity>() }
        var entities = allEntities
        
        for componentType in componentTypes {
            guard let componentsByEntity = componentsByEntityByType[ObjectIdentifier(componentType)] else { return Set<Entity>() }
            entities.formIntersection(Set(componentsByEntity.keys))
        }
        
        return entities
    }
    
    //  /// Gets a component of a given type for the list of entities. Ignores entities that do not exist or have no Components.
    //  public func get<ComponentType: Component>(_ componentType: ComponentType.Type, for entities: Set<Entity>) -> [Entity : ComponentType] {
    //    guard let componentsByEntity = componentsByEntityByType[ComponentTypeHash(type: componentType)] as? [Entity : ComponentType] else { return [Entity : ComponentType]() }
    //    return componentsByEntity.filter() { return entities.contains($0.key) }
    //  }
    
    //  /// Gets all the components of the given Types in the system for all entities.
    //  public func getAllComponents(of componentTypes: [Component.Type]) -> ComponentsByEntityByType {
    //    let componentTypeHashes = Set(componentTypes.map() { return ComponentTypeHash(type: $0) })
    //    return componentsByEntityByType.filter() { componentTypeHashes.contains($0.key) }
    //  }
    //
    //  /// Gets all the components of the given Types in the system for all entities.
    //  public func getAllComponents(of componentType: Component.Type) -> ComponentsByEntityByType {
    //    return getAllComponents(of: [componentType])
    //  }
    
//    /// Gets all components for a given entity. Throws EntitySyste,.Error if the entity does not exist. Runs O(x)
//    public func getAllComponents(for entities: [Entity]) -> [Entity : ComponentsByType] {
//        var entitiesAndComponents = [Entity : ComponentsByType]()
//        for entity in entities {
//            entitiesAndComponents[entity] = try? getAllComponents(for: entity)
//        }
//        return entitiesAndComponents
//    }
    
    /// Adds given componenta to an entity. Ignores components that already exist. Throws if the entity doesnt exist.
    public func add(_ components: [Component], to entity: Entity) throws {
        guard allEntities.contains(entity) else { throw Error.entityDoesNotExist(entity) }
        
        componentLoop: for component in components {
            let componentTypeHash = ObjectIdentifier(type(of: component))
            
            if componentsByEntityByType[componentTypeHash] != nil {
                guard componentsByEntityByType[componentTypeHash]?[entity] == nil else {
                    continue componentLoop
                    //          throw Error.entityAlreadyContainsComponent(entity: entity, componentType: type(of: component))
                }
                componentsByEntityByType[componentTypeHash]?[entity] = component
            } else {
                componentsByEntityByType[componentTypeHash] = [entity : component]
            }
        }
    }
    
    /// Adds given componenta to an entity. Replaces components that already exist.
    public func set(_ components: [Component], to entity: Entity) throws {
        guard allEntities.contains(entity) else { throw Error.entityDoesNotExist(entity) }
        
        for component in components {
            let componentTypeHash = ObjectIdentifier(type(of: component))
            
            if componentsByEntityByType[componentTypeHash] != nil {
                componentsByEntityByType[componentTypeHash]?[entity] = component
            } else {
                componentsByEntityByType[componentTypeHash] = [entity : component]
            }
        }
    }
    
    /// Removes all components of the types given
    public func removeAll(_ componentTypes: [Component.Type]) {
        for componentType in componentTypes {
            componentsByEntityByType[ObjectIdentifier(componentType)] = nil
        }
    }
    
    /// Removes all components of the types given from an entity
    public func remove(_ componentTypes: [Component.Type], from entity: Entity) {
        remove(componentTypes, from: [entity])
    }
    
    /// removes all components of the types given from the given entities
    public func remove(_ componentTypes: [Component.Type], from entities: [Entity]) {
        for componentType in componentTypes {
            let componentTypeHash = ObjectIdentifier(componentType.self)
            
            for entity in entities {
                if componentsByEntityByType[componentTypeHash] != nil {
                    componentsByEntityByType[componentTypeHash]?[entity] = nil
                }
            }
        }
    }
}
