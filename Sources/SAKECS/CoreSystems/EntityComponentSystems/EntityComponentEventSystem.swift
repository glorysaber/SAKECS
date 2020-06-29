//
//  EntityComponentEventSystem.swift
//  EmberEngine
//
//  Created by Stephen Kac on 8/6/18.
//

import Foundation
import SAKBase

public protocol EntityComponentEventSystem: EntityComponentSystem {
  // Optional Event handling functions
  func componentChanged(_ event: (change: ChangeEvent<ComponentFamilyID>, entity: Entity))
  func tagChanged(_ event: (change: ChangeEvent<Tag>, entity: Entity))
  func entityChanged(_ event: (change: ChangeType, entity: Entity))
}

extension EntityComponentEventSystem {
  
  public func componentChanged(_ event: (change: ChangeEvent<ComponentFamilyID>, entity: Entity)) {}
  public func tagChanged(_ event: (change: ChangeEvent<Tag>, entity: Entity)) {}
  public func entityChanged(_ event: (change: ChangeType, entity: Entity)) {}
  
  //  public func registerForChanges(with handler: @escaping (AnyObject) -> (((ChangeEvent<ComponentFamilyID>, Entity)) -> ()), components: EntityComponent.Type...) -> [Disposable?] {
  //    var disposables = [Disposable?]()
  //    for component in components {
  //      let disposable = ecs?.events.componentEvent.register(for: ChangeEvent.set(component.familyID()), with: self, handler: handler)
  //      disposables.append(disposable)
  //    }
  //    return disposables
  //  }
  
  /// Convenience function for registering for component change events
  public func registerForChanges(for changes: [ChangeType], of components: EntityComponent.Type...) -> [Disposable?] {
    var disposables = [Disposable?]()
    for component in components {
      if changes.contains(ChangeType.set) {
        let disposable = ecs?.events.componentEvent.register(for: ChangeEvent.set(component.familyID()), with: self, handler: Self.componentChanged)
        disposables.append(disposable)
      }
      if changes.contains(ChangeType.removed) {
        let disposable = ecs?.events.componentEvent.register(for: ChangeEvent.removed(component.familyID()), with: self, handler: Self.componentChanged)
        disposables.append(disposable)
      }
    }
    return disposables
  }
  
  /// Convenience function for registering for tag change events
  public func registerForChanges(for changes: [ChangeType], of tags: Tag...) -> [Disposable?] {
    var disposables = [Disposable?]()
    for tag in tags {
      if changes.contains(ChangeType.set) {
        let disposable = ecs?.events.tagEvent.register(for: ChangeEvent.set(tag), with: self, handler: Self.tagChanged)
        disposables.append(disposable)
      }
      if changes.contains(ChangeType.removed) {
        let disposable = ecs?.events.tagEvent.register(for: ChangeEvent.removed(tag), with: self, handler: Self.tagChanged)
        disposables.append(disposable)
      }
    }
    return disposables
  }
  
  /// Convenience function for registering for entity change events
  public func registerForEntityChanges(ofTypes changes: [ChangeType]) -> [Disposable?] {
    var disposables = [Disposable?]()
    if changes.contains(ChangeType.set) {
      let disposable = ecs?.events.entityEvent.register(for: ChangeType.set, with: self, handler: Self.entityChanged)
      disposables.append(disposable)
    }
    if changes.contains(ChangeType.removed) {
      let disposable = ecs?.events.entityEvent.register(for: ChangeType.removed, with: self, handler: Self.entityChanged)
      disposables.append(disposable)
    }
    return disposables
  }
}
