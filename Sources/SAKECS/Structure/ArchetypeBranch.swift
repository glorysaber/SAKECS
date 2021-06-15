//
//  ArchetypeBranch.swift
//  SAKECS
//
//  Created by Stephen Kac on 1/23/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation
import SAKBase
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

	private var sharedComponentsIndexes = [ComponentFamilyID: Int]()
	private var sharedComponents = [EntityComponent]()

	public init(
		componentArchetype: ComponentArchetype = [],
		chunkConstructor: @escaping () -> Chunk
	) {
		self.chunkConstructor = chunkConstructor
		self.componentArchetype = ComponentArchetype()
		_ = addChunk()
	}

	private init(_ branch: ArchetypeBranch) {
		self.chunkConstructor = branch.chunkConstructor
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
extension ArchetypeBranch: ComponentBranch {

	public func contains(componentWith familyID: ComponentFamilyID) -> Bool {
		componentArchetype.required.contains(familyID)
	}

	public mutating func remove(componentWith familyID: ComponentFamilyID) {
		chunks.modifying { modifyingChunks in
			modifyingChunks.forEach { $0.remove(componentWith: familyID) }
		}
		componentArchetype -= familyID
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

	public func contains(entity: Entity) -> Bool {
		// fixme: Transient memory in chunk read
		chunks.contains { $0.contains(entity: entity) }
	}

	public mutating func add(entity: Entity) {
		guard contains(entity: entity) == false else { return }

		let mutableChunk = chunks.modifying { mutableChunks in
			mutableChunks
				.first { $0.minimumCapacity > $0.entityCount }
		} ?? { addChunk() }()

		mutableChunk.add(entity: entity)
	}

	public mutating func remove(entity: Entity) {
		chunks.modifying { mutableChunks in
			mutableChunks.first(where: { $0.contains(entity: entity) })?
			.remove(entity: entity)
		}
	}

	public func contains<Component: EntityComponent>(component componentType: Component.Type) -> Bool {
		chunks.contains { $0.contains(component: componentType) }
	}

	public mutating func set<Component: EntityComponent>(component: Component, for entity: Entity) {
		chunks.modifying { mutableChunks in
			let chunk = mutableChunks.first(where: { $0.contains(entity: entity) })
			chunk?.set(component: component, for: entity)
		}
	}

	public mutating func add<Component: EntityComponent>(component componentType: Component.Type) {
		chunks.modifying { mutableChunks in
			mutableChunks.forEach { $0.add(component: componentType) }
		}
		componentArchetype += Component.familyID
	}

	public mutating func remove<Component: EntityComponent>(component componentType: Component.Type) {
		chunks.modifying { mutableChunks in
			mutableChunks.forEach { $0.remove(component: componentType) }
		}

		componentArchetype -= Component.familyID
	}

	public func get<Component: EntityComponent>(
		component componentType: Component.Type,
		for entity: Entity
	) -> Component? {
		chunks.first(where: { $0.contains(entity: entity) })?
			.get(component: componentType, for: entity)
	}
}

// MARK: - ArchetypeDeepCopy
extension ArchetypeBranch: ArchetypeDeepCopy {

	public var archetype: ArchetypeBranch<Chunk> {
		Self(self)
	}

	public func copyComponents(
		for entity: Entity,
		to destination: inout Self,
		destinationEntity: Entity
	) {
		let sourceChunk = chunks.first(where: { $0.contains(entity: entity) })

		destination.chunks.modifying { mutableDestinationChunks in
			guard let destinationChunk = mutableDestinationChunks.first(where: { $0.contains(entity: destinationEntity) }) else {
				fatalError("Precondition failure, there is no entity \(destinationEntity)")
			}

			sourceChunk?
				.copyComponents(
					for: entity,
						 to: &destinationChunk.wrappedValue,
						 destinationEntity: destinationEntity
				)
		}
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
		chunks.modifying { mutableChunks in
			let chunk = mutableChunks.first?.wrappedValue.archetype ?? {
				chunkConstructor()
			}()
			let container = Container(chunk)
			mutableChunks.append(container)
			return container
		}
	}
}
