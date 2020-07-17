//
//  CentralEventSystem.swift
//  EmberEngine
//
//  Created by Stephen Kac on 7/25/18.
//

import Foundation
import SAKBase

/// Where all events are registered for and stored
public class CentralEventSystem {
  public var tagEvent = EventSystem<ChangeEvent<EntityTag>, Entity>()
  public var componentEvent = EventSystem<ChangeEvent<ComponentFamilyID>, Entity>()
  public var entityEvent = EventSystem<ChangeType, Entity>()
  public var contactEvent = Event<(Entity, Entity)>()
}

public enum ChangeEvent<T: Hashable>: Hashable {
  case removed(T)
  case set(T)
}

public enum ChangeType: Hashable {
  case removed
  case set
}
