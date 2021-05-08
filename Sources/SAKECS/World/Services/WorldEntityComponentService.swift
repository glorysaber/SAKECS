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
	func containsComponent(
		with familyID: ComponentFamilyID
	) -> Bool

	/// Sets the component on the entity
	/// - Parameters:
	///   - component: The component object to set on the entity
	///   - entity: The entity to set it on.
	func set<ComponentType: EntityComponent>(
		_ component: ComponentType,
		to entity: Entity
	)

	/// Gets  the given component type if available.
	/// - Parameters:
	///   - componentType: The type of component to get
	///   - entity: The entity to get it for
	func get<ComponentType: EntityComponent>(
		_ componentType: ComponentType.Type,
		for entity: Entity
	) -> ComponentType?

	/// Removes the given component from the entity
	/// - Parameters:
	///   - familyID: The family ID associated with the component type
	///   - entity: The entity to remove the component from
	func removeComponent(
		with familyID: ComponentFamilyID,
		from entity: Entity
	)

	/// A possibly expensive operation
	/// - Parameters:
	///   - componentType: The type of component to remove
	///   - entity: The entity to remove the component from
	func remove<ComponentType: EntityComponent>(
		_ componentType: ComponentType.Type,
		from entity: Entity
	)

	/// Silently fails, removes the entity if it exists
	/// - Parameter entity: The identifier for the entity.
	func remove(entity: Entity)
}
