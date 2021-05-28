//
//  ArchetypeBranch.swift
//  SAKECS
//
//  Created by Stephen Kac on 1/23/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation
// While we can have any ArchetypeGroup we do expect them all to be the same
// And having them as hetrogenous types is inefficient. Fixing this later
// would require an API change at the site of initialization, so I am declaring this now.

/// A branch of like entity components
public typealias EntityComponentBranch = ArchetypeBranch<EntityComponentChunk>

/// A branch of like entity components
public struct ArchetypeBranch<Chunk: ArchetypeGroup> {

	typealias Container = MutableValueReference<Chunk>

	public var componentArchetype: ComponentArchetype

	/**
	All of the chunks should be of the same archetype, this must
	be gaurenteed by the branch..
	I use containers as I will need to alterthe contents without copying.
	*/
	private var chunks = MutableArray<Chunk>()

	private let chunkConstructor: () -> Chunk
	private let columnsInEachChunk: Int

	private var sharedComponentsIndexes = [ComponentFamilyID: Int]()
	private var sharedComponents = [EntityComponent]()

	public init(
		columnsInEachChunk: Int,
		componentArchetype: ComponentArchetype = [],
		chunkConstructor: @escaping () -> Chunk
	) {
		self.chunkConstructor = chunkConstructor
		self.columnsInEachChunk = columnsInEachChunk
		self.componentArchetype = ComponentArchetype()
		_ = addChunk()
	}

	private init(_ branch: ArchetypeBranch) {
		self.chunkConstructor = branch.chunkConstructor
		self.columnsInEachChunk = branch.columnsInEachChunk
		self.chunks = MutableArray(branch.chunks.map { $0.archetype })
		self.componentArchetype = branch.componentArchetype
	}
}

// MARK: - Shared Components
extension ArchetypeBranch {

	/// Sets a component for the branch.
	/// - Parameter component: The component to add or set
	public mutating func setShared<Component: EntityComponent>(_ component: Component) {
		if let index = sharedComponentsIndexes[Component.familyID] {
			sharedComponents[index] = component
		} else {
			sharedComponents.append(component)
			sharedComponentsIndexes[Component.familyID] =
				sharedComponents.endIndex.advanced(by: -1)
		}
	}

	/// Gets the shared component of the given type
	/// - Returns: The component or nil
	public func getShared<Component: EntityComponent>() -> Component? {
		guard let index = sharedComponentsIndexes[Component.familyID] else {
			return nil
		}

		return sharedComponents[index] as? Component
	}

	/// Gets the shared component of the given type
	/// - Returns: The component or nil
	public func getShared<Component: EntityComponent>(_ component: Component.Type) -> Component? {
		return getShared()
	}

	/// Removes the shared component if it exists
	/// - Parameter component: The component type to remove.
	public mutating func removeShared<Component: EntityComponent>(_ component: Component.Type) {
		guard let index = sharedComponentsIndexes[Component.familyID] else {
			return
		}

		sharedComponents.remove(at: index)

		for (key, value) in sharedComponentsIndexes where value > index {
			sharedComponentsIndexes[key] = value - 1
		}

		sharedComponentsIndexes[Component.familyID] = nil
	}
}

// MARK: - ArchetypeGroup
extension ArchetypeBranch: ArchetypeGroup {

	public func containsComponent(with familyID: ComponentFamilyID) -> Bool {
		componentArchetype.required.contains(familyID)
	}

	public mutating func removeComponent(with familyID: ComponentFamilyID) {
		chunks.firstContainer()?.removeComponent(with: familyID)
		componentArchetype -= familyID
	}

	public var archetype: ArchetypeBranch<Chunk> {
		Self(self)
	}

	public var entityCount: Int {
		chunks.reduce(0) { $0 + $1.entityCount }
	}

	public var componentTypeCount: Int {
		chunks.first?.componentTypeCount ?? 0
	}

	public var freeIndexCount: Int {
		chunks.reduce(0) { $0 + $1.freeIndexCount }
	}

	public var minimumCapacity: Int {
		chunks.first?.componentTypeCount ?? 0
	}

	public mutating func reserveCapacity(_ minimumCapcity: Int) {
		if minimumCapcity > self.minimumCapacity {
			chunks.forEachContainer { $0.reserveCapacity(minimumCapcity) }
		}
	}

	public func contains(_ entity: Entity) -> Bool {
		chunks.contains { $0.contains(entity) }
	}

	public mutating func add(entity: Entity) {
		guard contains(entity) == false else { return }

		let chunk = chunks.firstContainer { $0.minimumCapacity > $0.entityCount } ?? addChunk()

		chunk.add(entity: entity)
	}

	public mutating func remove(entity: Entity) {
		chunks.firstContainer(where: { $0.contains(entity) })?
			.remove(entity: entity)
	}

	public func contains<Component: EntityComponent>(_ componentType: Component.Type) -> Bool {
		chunks.contains { $0.contains(componentType) }
	}

	public mutating func set<Component: EntityComponent>(_ component: Component, for entity: Entity) {
		chunks.firstContainer(where: { $0.contains(entity) })?
			.set(component, for: entity)
	}

	public mutating func add<Component: EntityComponent>(_ componentType: Component.Type) {
		chunks.forEachContainer { $0.add(componentType) }
		componentArchetype += Component.familyID
	}

	public mutating func remove<Component: EntityComponent>(_ componentType: Component.Type) {
		chunks.forEachContainer { $0.remove(componentType) }
		componentArchetype -= Component.familyID
	}

	public func get<Component: EntityComponent>(_ componentType: Component.Type, for entity: Entity) -> Component? {
		chunks.first(where: { $0.contains(entity) })?
			.get(componentType, for: entity)
	}

	// MARK: - Moving Data

	public func copyComponents(for entity: Entity, to destination: inout Self, destinationEntity: Entity) {
		let sourceChunk = chunks.first(where: { $0.contains(entity) })
		guard let destinationChunk = destination.chunks.firstContainer(where: { $0.contains(destinationEntity) }) else {
			fatalError("Precondition failure, there is no entity \(destinationEntity)")
		}
		sourceChunk?.copyComponents(for: entity, to: &destinationChunk.wrappedValue, destinationEntity: destinationEntity)
	}
}

// MARK: - RandomAccessCollection
extension ArchetypeBranch: RandomAccessCollection {
	public typealias Element = Chunk

	public typealias Index = Int

	public var count: Int {
		chunks.count
	}

	public var startIndex: Int {
		chunks.startIndex
	}

	public var endIndex: Int {
		chunks.endIndex
	}

	public subscript(position: Int) -> Chunk {
		chunks[position]
	}
}

// MARK: - Chunk Management
private extension ArchetypeBranch {
	mutating func addChunk() -> Container {
		let chunk = chunks.first?.archetype ?? {
			var chunk = chunkConstructor()
			chunk.reserveCapacity(columnsInEachChunk)
			return chunk
		}()
		let container = Container(chunk)
		chunks.append(container)
		return container
	}
}
