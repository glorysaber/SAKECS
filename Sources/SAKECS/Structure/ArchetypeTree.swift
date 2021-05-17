//
//  ArchetypeTree.swift
//  SAKECS
//
//  Created by Stephen Kac on 4/24/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

typealias EntityComponentTree = ArchetypeTree<EntityComponentBranch>

class ArchetypeTree<Branch: ArchetypeGroup>: WorldEntityComponentService {

	private var branches = MutableArray<Branch>()

	var componentCount: Int {
		branches.reduce(Set<ComponentFamilyID>()) {
			$0.union($1.componentArchetype.required)
		}
		.count
	}

	func containsComponent(with familyID: ComponentFamilyID) -> Bool {
		branches.contains { $0.componentArchetype.required.contains(familyID) }
	}

	func set<ComponentType: EntityComponent>(_ componentType: ComponentType, to entity: Entity) {

		guard let sourceBranch = mutableBranch(for: entity) else { return }

		guard !sourceBranch.contains(ComponentType.self) else {
			// We are just changing a components value.
			sourceBranch.set(componentType, for: entity)
			return
		}

		// The new Archtype for the entitys
		let destinationArchetype = sourceBranch.componentArchetype + componentType.familyID
		let destinationBranch: MutableValueReference<Branch>

		if let existingBranchForNewArcheType = branches
				.firstContainer(where: { $0.componentArchetype == destinationArchetype }) {
			destinationBranch = existingBranchForNewArcheType
		} else {
			// First Create the branch for the archetype
			do {
				var newBranch = sourceBranch.wrappedValue.archetype
				newBranch.add(ComponentType.self)
				branches.append(newBranch)
			}

			// Now get its mutable container
			guard let newBranch = branches.firstContainer(where: { $0.componentArchetype == destinationArchetype }) else {
				assert(false, "We cannot find the branch we just created.")
			}

			destinationBranch = newBranch
		}

		move(entity: entity, from: sourceBranch, to: destinationBranch)
	}

	func get<ComponentType: EntityComponent>(_ componentType: ComponentType.Type, for entity: Entity) -> ComponentType? {
		branch(for: entity)?.get(componentType, for: entity)
	}

	func removeComponent(with familyID: ComponentFamilyID, from entity: Entity) {
		guard let sourceBranch = mutableBranch(for: entity) else { return }

		guard sourceBranch.containsComponent(with: familyID) else {
			// Nothing to do.
			return
		}

		// Now we need to move the entity to a proper branch.

		// The new Archtype for the entitys
		let destinationArchetype = sourceBranch.componentArchetype - familyID
		let destinationBranch: MutableValueReference<Branch>

		if let existingBranchForNewArcheType = branches
				.firstContainer(where: { $0.componentArchetype == destinationArchetype }) {
			destinationBranch = existingBranchForNewArcheType
		} else {
			// First Create the branch for the archetype
			do {
				var newBranch = sourceBranch.wrappedValue.archetype
				newBranch.removeComponent(with: familyID)
				branches.append(newBranch)
			}

			// Now get its mutable container
			guard let newBranch = branches.firstContainer(where: { $0.componentArchetype == destinationArchetype }) else {
				assert(false, "We cannot find the branch we just created.")
			}

			destinationBranch = newBranch
		}

		move(entity: entity, from: sourceBranch, to: destinationBranch)
	}

	func remove(entity: Entity) {
		mutableBranch(for: entity)?.remove(entity: entity)
	}
}

// MARK: - Helper
private extension ArchetypeTree {
	private func mutableBranch(for entity: Entity) -> MutableValueReference<Branch>? {
		branches
			// There should only be one instance where an entity appears.
			.firstContainer(
				where: { $0.contains(entity) }
			)
	}

	private func branch(for entity: Entity) -> Branch? {
		branches
			// There should only be one instance where an entity appears.
			.first(
				where: { $0.contains(entity) }
			)
	}

	func move(
		entity: Entity,
		from destinationBranch: MutableValueReference<Branch>,
		to sourceBranch: MutableValueReference<Branch>
	) {
		destinationBranch.add(entity: entity)
		sourceBranch.wrappedValue.copyComponents(for: entity, to: &destinationBranch.wrappedValue, destinationEntity: entity)
		sourceBranch.remove(entity: entity)
	}
}

extension MutableValueReference: ComponentBranch where Element: ComponentBranch {

	public var componentArchetype: ComponentArchetype {
		wrappedValue.componentArchetype
	}

	public var entityCount: Int {
		wrappedValue.entityCount
	}

	public var componentTypeCount: Int {
		wrappedValue.componentTypeCount
	}

	public var freeIndexCount: Int {
		wrappedValue.freeIndexCount
	}

	public var minimumCapacity: Int {
		wrappedValue.minimumCapacity
	}

	public func reserveCapacity(_ minimumCapcity: Int) {
		wrappedValue.reserveCapacity(minimumCapcity)
	}

	public func contains(_ entity: Entity) -> Bool {
		wrappedValue.contains(entity)
	}

	public func add(entity: Entity) {
		wrappedValue.add(entity: entity)
	}

	public func remove(entity: Entity) {
		wrappedValue.remove(entity: entity)
	}

	public func contains<Component>(_ componentType: Component.Type) -> Bool where Component: EntityComponent {
		wrappedValue.contains(componentType)
	}

	public func set<Component>(
		_ component: Component,
		for entity: Entity
	) where Component: EntityComponent {
		wrappedValue.set(component, for: entity)
	}

	public func add<Component>(
		_ componentType: Component.Type
	) where Component: EntityComponent {
		wrappedValue.add(componentType)
	}

	public func remove<Component>(
		_ componentType: Component.Type
	) where Component: EntityComponent {
		wrappedValue.remove(componentType)
	}

	public func get<Component>(
		_ componentType: Component.Type,
		for entity: Entity
	) -> Component? where Component: EntityComponent {
		wrappedValue.get(componentType, for: entity)
	}

	public func containsComponent(with familyID: ComponentFamilyID) -> Bool {
		wrappedValue.containsComponent(with: familyID)
	}

	public func removeComponent(with familyID: ComponentFamilyID) {
		wrappedValue.removeComponent(with: familyID)
	}
}
