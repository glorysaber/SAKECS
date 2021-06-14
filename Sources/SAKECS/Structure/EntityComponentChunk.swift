//
//  EntityComponentChunk.swift
//  SAKECS
//
//  Created by Stephen Kac on 1/1/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

/// Comprises a chunk of like entities of a specific archetype, all entities share the same types applied to it.
public struct EntityComponentChunk {
	public var freeIndexCount: Int = 0

	// MARK: - Types

	/// The row for a component in the components
	public typealias ComponentRowIndex = ComponentColumnIndex

	// MARK: - Properties

	public private(set) var componentArchetype: ComponentArchetype = []

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

	/// Only for the first get of this variable will it attempt to grow the storage to match...
	/// Should be equivalent to dispatch_once.
	private lazy var growStorageToMatchOnce: Void = {
		growStorageToMatch()
	}()
}

// MARK: - ArchetypeGroup
extension EntityComponentChunk: ArchetypeGroup {

	// MARK: - Moving Data

	public func copyComponents(for entity: Entity, to destination: inout Self, destinationEntity: Entity) {
		guard let sourceIndex = entities[entity] else { return }
		let destinationIndex = destination.getAndSetIndex(for: destinationEntity)

		components.copyComponents(for: sourceIndex, to: &destination.components, destinationColumnIndex: destinationIndex)
	}

	// MARK: - Entities

	public mutating func reserveCapacity(_ minimumCapacity: Int) {
		if minimumCapacity > self.minimumCapacity {
			self.minimumCapacity = minimumCapacity
		}
	}

	public var archetype: Self {
		var newArchetype = self
		newArchetype.emptyColumnsIndices.formUnion(newArchetype.entities.values)
		newArchetype.entities.removeAll(keepingCapacity: true)
		return newArchetype
	}

	public func contains(entity: Entity) -> Bool {
		entities.keys.contains(entity)
	}

	public mutating func add(entity: Entity) {
		getAndSetIndex(for: entity)
	}

	public mutating func remove(entity: Entity) {
		if let index = entities.removeValue(forKey: entity) {
			emptyColumnsIndices.insert(index)
		}
	}

	// MARK: Components

	public func contains<Component: EntityComponent>(component componentType: Component.Type) -> Bool {
		components.contains(rowOf: componentType)
	}

	public func contains(componentWith familyID: ComponentFamilyID) -> Bool {
		components.contains(rowWith: familyID)
	}

	public mutating func set<Component: EntityComponent>(component: Component, for entity: Entity) {
		guard
			let columnIndex = entities[entity],
			columnIndex != .invalid
		else { return }
		components.set(component: component, for: columnIndex)
	}

	public mutating func add<Component: EntityComponent>(component componentType: Component.Type) {
		components.add(rowFor: componentType)

		// We can get into a situation where an entity has already been added but the components
		// storage has no columns. This should be optimized away by most modern cpus by branch prediction
		// once it has ran once.
		_ = growStorageToMatchOnce
	}

	public mutating func remove<Component: EntityComponent>(component componentType: Component.Type) {
		components.remove(rowOf: componentType)
	}

	public mutating func remove(componentWith familyID: ComponentFamilyID) {
		components.remove(rowWith: familyID)
	}

	public func get<Component: EntityComponent>(
		component componentType: Component.Type,
		for entity: Entity
	) -> Component? {
		guard
			let columnIndex = entities[entity],
			columnIndex != .invalid
		else { return nil }
		return components.get(component: componentType, for: columnIndex)
	}
}

// MARK: - Private Helpers
private extension EntityComponentChunk {
	/// Grows the internal storage of a the component matrix to match the
	/// size of the entities or the minimum component size
	private mutating func growStorageToMatch() {
		guard entities.count > components.componentColumns else {
			return
		}

		let columnsToAdd = Swift.max(entities.count - components.componentColumns, minimumCapacity)
		let newIndexes = components.addColumns(columnsToAdd)
		emptyColumnsIndices.formUnion(ClosedRange(newIndexes))

		for (entity, column) in entities where column == .invalid && emptyColumnsIndices.isEmpty == false {
			entities[entity] = emptyColumnsIndices.removeFirst()
		}

		precondition(entities.count <= components.componentColumns)
	}

	@discardableResult
	mutating func getAndSetIndex(for entity: Entity) -> ComponentColumnIndex {
		let index = emptyColumnsIndices.popFirst() ??
		components.addColumns(1).first ??
			.invalid
		entities[entity] = index
		return index
	}
}
