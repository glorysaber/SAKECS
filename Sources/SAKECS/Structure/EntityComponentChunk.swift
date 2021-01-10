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

	/// Default Initializer
	public init() {}

	/// - Parameter entity: The entity to check for
	/// - Returns: true if the entity record exists, false otherwise
	func contains(_ entity: Entity) -> Bool {
		entities.keys.contains(entity)
	}

	/// Adds an entity entry to this chunk, grows the underlying storage to accomodate it
	/// - Parameter entity: The entity to add
	public mutating func add(entity: Entity) {
		entities[entity] = components.addColumns(1)
	}

	/// Removes an entity entry if it exists
	/// - Parameter entity: The entity to remove
	public mutating func remove(entity: Entity) {
		entityComponentRowMap.removeValue(forKey: entity)
	}

}
