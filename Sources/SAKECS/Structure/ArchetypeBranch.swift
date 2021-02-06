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

	fileprivate final class Container {
		var chunk: Chunk = Chunk()
		required init() {}
	}

	public init() {}

	/**
	All of the chunks should be of the same archetype, this must
	be gaurenteed by the branch..
	*/
	private var componentChunks = [Container()]
}

extension ArchetypeBranch: ArchetypeGroup {

	public var entityCount: Int {
		componentChunks.reduce(0) { $0 + $1.entityCount }
	}

	public var componentTypeCount: Int {
		componentChunks.first?.componentTypeCount ?? 0
	}

	public var freeIndexCount: Int {
		componentChunks.reduce(0) { $0 + $1.freeIndexCount }
	}

	public var minimumCapacity: Int {
		componentChunks.first?.componentTypeCount ?? 0
	}

	public mutating func reserveCapacity(_ minimumCapcity: Int) {
		if minimumCapcity > self.minimumCapacity {
			componentChunks.forEach { $0.reserveCapacity(minimumCapcity) }
		}
	}

	public func contains(_ entity: Entity) -> Bool {
		componentChunks.contains { $0.contains(entity) }
	}

	public mutating func add(entity: Entity) {
		// adding more than one chunk will be based on performance... so one chunk passes all tests for now.
		let chunk = componentChunks.first ?? {
			let chunk = Container()
			componentChunks.append(chunk)
			return chunk
		}()

		chunk.add(entity: entity)
	}

	public mutating func remove(entity: Entity) {
		componentChunks.first(where: { $0.contains(entity) })?
			.remove(entity: entity)
	}

	public func contains<Component: EntityComponent>(_ componentType: Component.Type) -> Bool {
		componentChunks.contains { $0.contains(componentType) }
	}

	public mutating func set<Component: EntityComponent>(_ component: Component, for entity: Entity) {
		componentChunks.first(where: { $0.contains(entity) })?
			.set(component, for: entity)
	}

	public mutating func add<Component: EntityComponent>(_ componentType: Component.Type) {
		componentChunks.forEach { $0.add(componentType) }
	}

	public mutating func remove<Component: EntityComponent>(_ componentType: Component.Type) {
		componentChunks.forEach { $0.remove(componentType) }
	}

	public func get<Component: EntityComponent>(_ componentType: Component.Type, for entity: Entity) -> Component? {
		componentChunks.first(where: { $0.contains(entity) })?
			.get(componentType, for: entity)
	}
}

extension ArchetypeBranch.Container: ArchetypeGroup {
	var entityCount: Int {
		chunk.entityCount
	}

	var componentTypeCount: Int {
		chunk.componentTypeCount
	}

	var freeIndexCount: Int {
		chunk.freeIndexCount
	}

	var minimumCapacity: Int {
		chunk.minimumCapacity
	}

	func reserveCapacity(_ minimumCapcity: Int) {
		chunk.reserveCapacity(minimumCapcity)
	}

	func contains(_ entity: Entity) -> Bool {
		chunk.contains(entity)
	}

	func add(entity: Entity) {
		chunk.add(entity: entity)
	}

	func remove(entity: Entity) {
		chunk.remove(entity: entity)
	}

	func contains<Component: EntityComponent>(_ componentType: Component.Type) -> Bool {
		chunk.contains(componentType)
	}

	func set<Component: EntityComponent>(_ component: Component, for entity: Entity) {
		chunk.set(component, for: entity)
	}

	func add<Component: EntityComponent>(_ componentType: Component.Type) {
		chunk.add(componentType)
	}

	func remove<Component: EntityComponent>(_ componentType: Component.Type) {
		chunk.remove(componentType)
	}

	func get<Component: EntityComponent>(_ componentType: Component.Type, for entity: Entity) -> Component? {
		chunk.get(componentType, for: entity)
	}
}
