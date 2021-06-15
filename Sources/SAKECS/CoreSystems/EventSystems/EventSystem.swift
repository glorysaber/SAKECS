//
//  EventSystem.swift
//  EmberEngine
//
//  Created by Stephen Kac on 7/18/18.
//

import Foundation
import SAKBase

/// A system that allows events to be registered for and raised for a given type
public final class EventSystem<EventKey: Hashable, EventValue: Any> {
	public typealias RaisedValue = (EventKey, EventValue)
	public typealias Handler = (RaisedValue) -> Void

	/// All events for the EventKeys
	internal var events = [EventKey: Event<RaisedValue>]()

	public init() {}

	/// Registers a class for an event witch is tied to the classes lifespan by the DisposeContainer.
	public func register(
		for event: EventKey,
		handler: @escaping Handler) -> DisposeContainer {
		if let event = events[event] {
			return event.addHandler(handler: handler)
		} else {
			let newEvent = Event<RaisedValue>()
			let disp = newEvent.addHandler(handler: handler)
			events[event] = newEvent
			return disp
		}
	}

	/// Raises the event for all listeners
	public func raise(_ event: EventKey, value: EventValue) {
		if OperationQueue.current == OperationQueue.main {
			events[event]?.raise((event, value))
		} else {
			OperationQueue.main.addOperation { [weak self] in
				self?.events[event]?.raise((event, value))
			}
		}
	}
}
