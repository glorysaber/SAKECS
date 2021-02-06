//
//  EntityComponentChunk.swift
//  SAKECS
//
//  Created by Stephen Kac on 1/1/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

/// Comprises a chunk of like entities of a specific archetype, all entities share the same types applied to it.
public struct EntityComponentChunk: ArchetypeGroup {
	public var freeIndexCount: Int = 0

	// MARK: - Types

	/// The row for a component in the components
	private typealias ComponentRowIndex = ComponentColumnIndex

	// MARK: - Properties

	/// Count of entities
	public var entityCount: Int {
		entities.count
	}

	/// Count of componentTypes
	public var componentTypeCount: Int {
		components.count
	}

	// MARK: private

	/// Entity map to their row
	private var entities = [Entity: ComponentRowIndex]()

	/// The components for the entities
	private var components = ComponentMatrix()

	/// Unused component ColumnsIndices
	private var emptyColumnsIndices = Set<ComponentColumnIndex>()

	/// Take this into account to reduce allocations
	public var minimumCapacity: Int = 0 {
		didSet {
			entities.reserveCapacity(minimumCapacity)
			emptyColumnsIndices.reserveCapacity(minimumCapacity)
			if minimumCapacity - components.componentColumns > 0 {
				let newIndexes = components.addColumns(minimumCapacity - components.count)
				emptyColumnsIndices.formUnion(newIndexes)
			}
		}
	}

	// MARK: - LifeCycle
	public init() {}

	// MARK: - Entities

	public mutating func reserveCapacity(_ minimumCapacity: Int) {
		if minimumCapacity > self.minimumCapacity {
			self.minimumCapacity = minimumCapacity
		}
	}

	/// - Parameter entity: The entity to check for
	/// - Returns: true if the entity record exists, false otherwise
	public func contains(_ entity: Entity) -> Bool {
		entities.keys.contains(entity)
	}

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

	/// - Parameter componentType: The component type to check for
	/// - Returns: true if the entity componentType exists, false otherwise
	public func contains<Component: EntityComponent>(_ componentType: Component.Type) -> Bool {
		components.contains(componentType)
	}

	/// If the given enity exists, set this component.
	/// If the component does not exist in the chunk does nothing.
	/// - Parameters:
	///   - component: The object to set
	///   - entity: the entity to find the column for and set the component
	public mutating func set<Component: EntityComponent>(_ component: Component, for entity: Entity) {
		guard let columnIndex = entities[entity] else { return }
		components.set(component, for: columnIndex)
	}

	/// Adds the given componentType if it does not already exist
	/// - Parameters:
	///   - componentType: The component type to add
	public mutating func add<Component: EntityComponent>(_ componentType: Component.Type) {
		components.add(componentType)

		// We can get into a situation where an entity has already been added but the components
		// storage has no columns. This should be optimized away by most modern cpus by branch prediction
		// once it has ran once.
		_ = growStorageToMatchOnce
	}

	/// removes the given componentType if it exists
	/// - Parameters:
	///   - componentType: The component type to remove
	public mutating func remove<Component: EntityComponent>(_ componentType: Component.Type) {
		components.remove(componentType)
	}

	/// Gets the given component for the entity or nil otherwise
	/// - Parameters:
	///   - componentType: The component type to get
	///   - entity: The Entity to get the component for
	/// - Returns: The component if the component exists, nil otherwise
	public func get<Component: EntityComponent>(
		_ componentType: Component.Type,
		for entity: Entity
	) -> Component? {
		guard let columnIndex = entities[entity] else { return nil }
		return components.get(componentType, for: columnIndex)
	}

	// MARK: - Private Helpers

	private lazy var growStorageToMatchOnce: Void = {
		growStorageToMatch()
	}()

	private mutating func growStorageToMatch() {
		guard entities.count > components.componentColumns else {
			return
		}

		emptyColumnsIndices.formUnion(components.addColumns(entities.count - components.componentColumns))

		for (entity, column) in entities where column == .invalid && emptyColumnsIndices.isEmpty == false {
			entities[entity] = emptyColumnsIndices.removeFirst()
		}

		precondition(entities.count <= components.componentColumns)
	}
}
