//
//  ArchetypeGroup.swift
//  SAKECS
//
//  Created by Stephen Kac on 1/23/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

public protocol ArchetypeGroup {
	/// Count of entities
	var entityCount: Int { get }

	/// Count of componentTypes
	var componentTypeCount: Int { get }

	/// The count of free indexes current available
	var freeIndexCount: Int { get }

	/// Take this into account to reduce allocations
	var minimumCapacity: Int { get }

	// MARK: Initialization
	init()

	// MARK: Storage

	/// Reserves capacity for the given amount of entities. Best used after you have assigned the component types.
	/// - Parameter for: The count of enties to reserve capcity for.
	mutating func reserveCapacity(_ minimumCapcity: Int)

	// MARK: Entities

	/// - Parameter entity: The entity to check for
	/// - Returns: true if the entity record exists, false otherwise
	func contains(_ entity: Entity) -> Bool

	/// Adds an entity entry
	///  It will not produce an index for an entity if
	/// - Parameter entity: The entity to add
	mutating func add(entity: Entity)

	/// Sets an entity entry as empty if it exists
	/// - Parameter entity: The entity to remove
	mutating func remove(entity: Entity)

	// MARK: Components

	/// - Parameter componentType: The component type to check for
	/// - Returns: true if the entity componentType exists, false otherwise
	func contains<Component: EntityComponent>(_ componentType: Component.Type) -> Bool

	/// If the given enity exists, set this component.
	/// If the component does not exist in the chunk does nothing.
	/// - Parameters:
	///   - component: The object to set
	///   - entity: the entity to find the column for and set the component
	mutating func set<Component: EntityComponent>(_ component: Component, for entity: Entity)

	/// Adds the given componentType if it does not already exist
	/// - Parameters:
	///   - componentType: The component type to add
	mutating func add<Component: EntityComponent>(_ componentType: Component.Type)

	/// removes the given componentType if it exists
	/// - Parameters:
	///   - componentType: The component type to remove
	mutating func remove<Component: EntityComponent>(_ componentType: Component.Type)

	/// Gets the given component for the entity or nil otherwise
	/// - Parameters:
	///   - componentType: The component type to get
	///   - entity: The Entity to get the component for
	/// - Returns: The component if the component exists, nil otherwise
	func get<Component: EntityComponent>(
		_ componentType: Component.Type,
		for entity: Entity
	) -> Component?
}
