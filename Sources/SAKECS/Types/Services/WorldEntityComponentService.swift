//
//  WorldEntityComponentService.swift
//  SAKECS
//
//  Created by Stephen Kac on 2/18/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

public protocol WorldEntityComponentService {
	var componentCount: Int { get }

	/// Checks if an enity contains a given component
	/// - Parameter componentType: The type of  component to check for
	func contains<ComponentType: EntityComponent>(
		_ componentType: ComponentType.Type
	) -> Bool

	/// Checks if an enity contains a given component
	/// - Parameter familyID: The type of  component to check for
	func contains(
		componentWith familyID: ComponentFamilyID
	) -> Bool

	/// Sets the component on the entity
	/// - Parameters:
	///   - component: The component object to set on the entity
	///   - entity: The entity to set it on.
	mutating func set<ComponentType: EntityComponent>(
		component: ComponentType,
		to entity: Entity
	)

	/// Gets  the given component type if available.
	/// - Parameters:
	///   - componentType: The type of component to get
	///   - entity: The entity to get it for
	func get<ComponentType: EntityComponent>(
		component componentType: ComponentType.Type,
		for entity: Entity
	) -> ComponentType?

	/// Removes the given component from the entity
	/// - Parameters:
	///   - familyID: The family ID associated with the component type
	///   - entity: The entity to remove the component from
	mutating func remove(
		componentWith familyID: ComponentFamilyID,
		from entity: Entity
	)

	/// A possibly expensive operation
	/// - Parameters:
	///   - componentType: The type of component to remove
	///   - entity: The entity to remove the component from
	mutating func remove<ComponentType: EntityComponent>(
		_ componentType: ComponentType.Type,
		from entity: Entity
	)

	/// Silently fails, removes the entity if it exists
	/// - Parameter entity: The identifier for the entity.
	mutating func remove(entity: Entity)
}

extension WorldEntityComponentService {
	/// Checks if an enity contains a given component
	/// - Parameter componentType: The type of  component to check for
	func contains<ComponentType>(_ componentType: ComponentType.Type) -> Bool where ComponentType: EntityComponent {
		 contains(componentWith: ComponentType.familyID)
	}

	/// A possibly expensive operation
	/// - Parameters:
	///   - componentType: The type of component to remove
	///   - entity: The entity to remove the component from
	mutating func remove<ComponentType: EntityComponent>(
		_ componentType: ComponentType.Type,
		from entity: Entity
	) {
		remove(componentWith: ComponentType.familyID, from: entity)
	}

	/// Sets the component on the entity
	/// - Parameters:
	///   - component: The component object to set on the entity
	///   - entity: The entity to set it on.
	mutating func set(
		component anyComponent: AnyEntityComponent,
		to entity: Entity
	) {
		anyComponent.component.set(to: &self, for: entity)
	}
}

private extension EntityComponent {
	func set<Service: WorldEntityComponentService>(to service: inout Service, for entity: Entity) {
		service.set(component: self, to: entity)
	}
}
