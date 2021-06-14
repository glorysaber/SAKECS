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
	func componentChanged(_ event: (change: ChangeEvent<ComponentFamilyID>,
																	entity: Entity))
	func tagChanged(_ event: (change: ChangeEvent<EntityTag>, entity: Entity))
	func entityChanged(_ event: (change: ChangeType, entity: Entity))
}

extension EntityComponentEventSystem {

	public func componentChanged(_ event: (
																change: ChangeEvent<ComponentFamilyID>,
																entity: Entity)) {}
	public func tagChanged(_ event: (change: ChangeEvent<EntityTag>, entity: Entity)) {}
	public func entityChanged(_ event: (change: ChangeType, entity: Entity)) {}

	/// Convenience function for registering for component change events
	public func registerForChanges(
		for changes: [ChangeType],
		of components: EntityComponent.Type...)
	-> [DisposeContainer] {

		guard let ecs = ecs else {
			return []
		}

		var disposables = [DisposeContainer]()

		for component in components {
			for change in changes {
				let disposeContainer: DisposeContainer
				switch change {
				case .removed:
					disposeContainer = ecs.events.componentEvent.register(
						for: ChangeEvent.removed(component.familyID),
						handler: { self.componentChanged($0) })
					disposables.append(disposeContainer)
				case .added:
					disposeContainer = ecs.events.componentEvent.register(
						for: ChangeEvent.added(component.familyID),
						handler: { self.componentChanged($0) })
				case .assigned:
					disposeContainer = ecs.events.componentEvent.register(
						for: ChangeEvent.assigned(component.familyID),
						handler: { self.componentChanged($0) })
				}

				disposables.append(disposeContainer)
			}
		}

		return disposables
	}

	/// Convenience function for registering for tag change events
	public func registerForChanges(for changes: [ChangeType], of tags: EntityTag...) -> [DisposeContainer] {
		guard let ecs = ecs else {
			return []
		}

		var disposables = [DisposeContainer]()

		for tag in tags {
			for change in changes {
				let disposeContainer: DisposeContainer
				switch change {
				case .removed:
					disposeContainer = ecs.events.tagEvent.register(
						for: ChangeEvent.removed(tag),
						handler: { self.tagChanged($0) })
				case .assigned:
					disposeContainer = ecs.events.tagEvent.register(
						for: ChangeEvent.assigned(tag),
						handler: { self.tagChanged($0) })
				case .added:
					disposeContainer = ecs.events.tagEvent.register(
						for: ChangeEvent.added(tag),
						handler: { self.tagChanged($0) })
				}
				disposables.append(disposeContainer)
			}
		}

		return disposables
	}

	/// Convenience function for registering for entity change events
	public func registerForEntityChanges(ofTypes changes: [ChangeType])
	-> [DisposeContainer] {
		guard let ecs = ecs else {
			return []
		}

		var disposables = [DisposeContainer]()

		for change in changes {
			let disposeContainer: DisposeContainer
			switch change {
			case .removed:
				disposeContainer = ecs.events.entityEvent.register(
					for: ChangeType.removed,
					handler: { self.entityChanged($0) })
				disposables.append(disposeContainer)
			case .assigned:
				disposeContainer = ecs.events.entityEvent.register(
					for: ChangeType.assigned,
					handler: { self.entityChanged($0) })
			case .added:
				disposeContainer = ecs.events.entityEvent.register(
					for: ChangeType.added,
					handler: { self.entityChanged($0) })
			}
			disposables.append(disposeContainer)
		}

		return disposables
	}
}
