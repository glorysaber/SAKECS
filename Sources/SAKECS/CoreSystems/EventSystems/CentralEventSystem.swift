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

public struct ChangeEvent<T: Hashable>: Hashable {
	public static func added(_ value: T) -> ChangeEvent {
		ChangeEvent(type: [.added, .assigned], value: value)
	}

	public static func removed(_ value: T) -> ChangeEvent {
		ChangeEvent(type: [.removed], value: value)
	}

	public static func assigned(_ value: T) -> ChangeEvent {
		ChangeEvent(type: [.assigned], value: value)
	}

	let type: Set<ChangeType>
	let value: T
}

public enum ChangeType: Hashable {
	// The value type or content was removed, useful if you only care when a type is initially added
  case removed
	// An value was assigned or reassigned, this is useful if you care ANYTIME an event is added/changed
  case assigned
	// Value was added when there was no like value before, useful if you only care when a type is initially added
	case added
}
