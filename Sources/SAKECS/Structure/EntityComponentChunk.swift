//
//  EntityComponentChunk.swift
//  SAKECS
//
//  Created by Stephen Kac on 1/1/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

/// Comprises a chunk of like entities of a specific archetype, all entities share the same types applied to it.
public struct EntityComponentChunk {
	/// The row for a component in the components
	typealias ComponentRowIndex = ComponentColumnIndex

	/// Count of entities
	private(set) var entities = [Entity: ComponentRowIndex]()

	/// The components for the entities
	private(set) var components = ComponentMatrix()

	/// Unused component ColumnsIndices
	private var emptyColumnsIndices = Set<ComponentRowIndex>()

	/// Default Initializer
	public init() {}

	/// - Parameter entity: The entity to check for
	/// - Returns: true if the entity record exists, false otherwise
	func contains(_ entity: Entity) -> Bool {
		entities.keys.contains(entity)
	}

	// MARK: Entities

	/// Adds an entity entry to this chunk, grows the underlying storage to accomodate it.
	///  It will not produce an index for an entity if
	/// - Parameter entity: The entity to add
	public mutating func add(entity: Entity) {
		entities[entity] =
			emptyColumnsIndices.first ??
			components.addColumns(1).first ??
			.invalid
	}

	/// Sets an entity entry as empty if it exists
	/// - Parameter entity: The entity to remove
	public mutating func remove(entity: Entity) {
		if let index = entities.removeValue(forKey: entity) {
			emptyColumnsIndices.insert(index)
		}
	}

	// MARK: Components

	/// If the given enity exists, set this component.
	/// If the component does not exist in the chunk does nothing.
	/// - Parameters:
	///   - component: The object to set
	///   - entity: the entity to find the column for and set the component
	public mutating func set<Component: EntityComponent>(_ component: Component, for entity: Entity) {
		guard let columnIndex = entities[entity] else { return }
		components.set(component, for: columnIndex)
	}

	/// Adds the given componentType, throws if the component type already exists
	/// - Parameters:
	///   - component: The object to set
	///   - entity: the entity to find the column for and set the component
	public mutating func add<Component: EntityComponent>(_ componentType: Component.Type) {
		components.add(componentType)
	}

}
