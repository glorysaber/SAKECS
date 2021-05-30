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
	private let branchConstructor: () -> Branch

	var componentCount: Int {
		branches.reduce(Set<ComponentFamilyID>()) {
			$0.union($1.componentArchetype.required)
		}
		.count
	}

	init(branchConstructor: @escaping () -> Branch) {
		self.branchConstructor = branchConstructor
	}

	func containsComponent(with familyID: ComponentFamilyID) -> Bool {
		branches.contains { $0.componentArchetype.required.contains(familyID) }
	}

	func set<ComponentType: EntityComponent>(_ component: ComponentType, to entity: Entity) {

		guard let sourceBranch = mutableBranch(for: entity) else {
			// Create a branch
			let newBranch = newMutableBranch()
			newBranch.add(ComponentType.self)
			newBranch.add(entity: entity)
			newBranch.set(component, for: entity)
			return
		}

		guard !sourceBranch.contains(ComponentType.self) else {
			// We are just changing a components value.
			sourceBranch.set(component, for: entity)
			return
		}

		// The new Archtype for the entitys
		let destinationArchetype = sourceBranch.componentArchetype + component.familyID
		let destinationBranch: MutableValueReference<Branch>

		if let existingBranchForNewArcheType = mutableBranch(for: destinationArchetype) {
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
				fatalError("We cannot find the branch we just created.")
			}

			destinationBranch = newBranch
		}

		move(entity: entity, from: sourceBranch, to: destinationBranch)
		destinationBranch.set(component, for: entity)
		print(destinationBranch)
		print(sourceBranch)
		print(branches)
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

		if let existingBranchForNewArcheType = mutableBranch(for: destinationArchetype) {
			destinationBranch = existingBranchForNewArcheType
		} else {
			// First Create the branch for the archetype
			do {
				var newBranch = sourceBranch.wrappedValue.archetype
				newBranch.removeComponent(with: familyID)
				branches.append(newBranch)
			}

			// Now get its mutable container
			guard let newBranch = mutableBranch(for: destinationArchetype) else {
				fatalError("We cannot find the branch we just created.")
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

	/// Gets the component types the given entity.
	/// - Parameter entity: The entity to get component types for
	/// - Return Set<ComponentFamilyID>: empty if entity does not exist
	func componentTypes(for entity: Entity) -> Set<ComponentFamilyID> {
		branch(for: entity)?.componentArchetype.required ?? []
	}

	private func mutableBranch(for entity: Entity) -> MutableValueReference<Branch>? {
		branches
			// There should only be one instance where an entity appears.
			.firstContainer { $0.contains(entity) }

	}

	private func branch(for entity: Entity) -> Branch? {
		branches
			// There should only be one instance where an entity appears.
			.first { $0.contains(entity) }
	}

	private func branch(for archetype: ComponentArchetype) -> Branch? {
		branches
			// There should only be one instance where an archetype exists
			.first { $0.componentArchetype == archetype }
	}

	private func mutableBranch(for archetype: ComponentArchetype) -> MutableValueReference<Branch>? {
		branches
			// There should only be one instance where an archetype exists.
			.firstContainer { $0.componentArchetype == archetype }
	}

	private func newMutableBranch(archetype: ComponentArchetype = []) -> MutableValueReference<Branch> {
		let mutableBranch = MutableValueReference(branchConstructor())

		branches.append(mutableBranch)

		archetype.required.forEach { $0.componentType.add(to: mutableBranch) }

		return mutableBranch
	}

	/// Moves the given entity to a new branch remove it from the old one.
	/// - Parameters:
	///   - entity: The entity to mvoe
	///   - sourceBranch: The source branch to move from
	///   - destinationBranch: The destination branch.
	private func move(
		entity: Entity,
		from sourceBranch: MutableValueReference<Branch>,
		to destinationBranch: MutableValueReference<Branch>
	) {
		// The destiantion branch must already have the given entity.
		destinationBranch.add(entity: entity)

		sourceBranch.wrappedValue.copyComponents(
			for: entity,
			to: &destinationBranch.wrappedValue,
			destinationEntity: entity
		)

		// We no longer need the original entity
		sourceBranch.remove(entity: entity)
	}
}

// MARK: - Dynamic Type Helpers

private extension EntityComponent {

	/// Used to add a generic type to a branch.
	/// - Parameters:
	///   - branch: The branch to add the component to
	static func add<Branch: ComponentBranch>(to branch: MutableValueReference<Branch>) {
		branch.add(Self.self)
	}
}
