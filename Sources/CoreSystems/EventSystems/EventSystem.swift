//
//  EventSystem.swift
//  EmberEngine
//
//  Created by Stephen Kac on 7/18/18.
//

import Foundation
import SAKBase

/// A system that allows events to be registered for and raised for a given type
public class EventSystem<EventKey: Hashable, EventValue: Any> {
  public typealias RaisedValue = (EventKey, EventValue)
  
  /// All events for the EventKeys
  internal var events = Dictionary<EventKey, Event<RaisedValue>>()
  
  public init() {}
  
  /// Registers a class for an event witch is tied to the classes lifespan or can be disposed with the returned Disposable item.
  public func register<Target>(for event: EventKey, with target: Target, handler: @escaping (Target) -> ((RaisedValue) -> ())) -> Disposable? where Target : AnyObject {
    if events[event] != nil {
      return events[event]?.addHandler(target, handler: handler)
    } else {
      let newEvent = Event<RaisedValue>()
      let disp = newEvent.addHandler(target, handler: handler)
      events[event] = newEvent
      return disp
    }
  }
  
  /// Regisers a target to have its handler called when the even is raised. Objects are autmatically deregistered once
  public func register(for event: EventKey, with target: AnyObject, handler: @escaping ((AnyObject, RaisedValue) -> (Bool))) -> Disposable? {
    if events[event] != nil {
      return events[event]?.addHandler(target, handler: handler)
    } else {
      let newEvent = Event<RaisedValue>()
      let disp = newEvent.addHandler(target, handler: handler)
      events[event] = newEvent
      return disp
    }
  }
  
  /// Tells all the listeners for the event
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

//public protocol EventSystem {
//  /// This is the type for events
//  associatedtype EventKey: Hashable
//
//  /// Event Value
//  associatedtype EventValue: Any
//
//  /// Events you can register for from the class
////  var events: Dictionary<EventKey, Event<EventValue>> { get set }
//  func register<Target: AnyObject>(for event: EventKey, with target: Target, handler: @escaping (Target) -> ((EventValue) -> ())) -> Disposable?
//}

//extension EventSystem {
//  func register<Target: AnyObject>(for event: EventKey, with target: Target, handler: @escaping (Target) -> ((EventValue) -> ())) -> Disposable? {
//    if events[event] != nil {
//      return events[event]?.addHandler(target, handler: handler)
//    } else {
//      let newEvent = Event<EventValue>()
//      let disp = newEvent.addHandler(target, handler: handler)
//      events[event] = newEvent
//      return disp
//    }
//  }
//}

