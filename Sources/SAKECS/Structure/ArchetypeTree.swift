//
//  ArchetypeTree.swift
//  SAKECS
//
//  Created by Stephen Kac on 4/24/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation
import SAKBase

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

	func contains(componentWith familyID: ComponentFamilyID) -> Bool {
		branches.contains { $0.componentArchetype.required.contains(familyID) }
	}

	func set<ComponentType: EntityComponent>(component: ComponentType, to entity: Entity) {

		guard let sourceBranch = mutableBranch(for: entity) else {
			// Create a branch
			let newBranch = newMutableBranch()
			newBranch.add(component: ComponentType.self)
			newBranch.add(entity: entity)
			newBranch.set(component: component, for: entity)
			return
		}

		guard !sourceBranch.contains(component: ComponentType.self) else {
			// We are just changing a components value.
			sourceBranch.set(component: component, for: entity)
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
				newBranch.add(component: ComponentType.self)
				branches.append(newBranch)
			}

			destinationBranch = branches.modifying { mutableBranches in
				// Now get its mutable container
				guard let newBranch = mutableBranches.first(where: { $0.componentArchetype == destinationArchetype }) else {
					fatalError("We cannot find the branch we just created.")
				}

				return newBranch
			}
		}

		move(entity: entity, from: sourceBranch, to: destinationBranch)
		destinationBranch.set(component: component, for: entity)
	}

	func get<ComponentType: EntityComponent>(
		component componentType: ComponentType.Type,
		for entity: Entity
	) -> ComponentType? {
		branch(for: entity)?.get(component: componentType, for: entity)
	}

	func remove(componentWith familyID: ComponentFamilyID, from entity: Entity) {
		guard let sourceBranch = mutableBranch(for: entity) else { return }

		guard sourceBranch.contains(componentWith: familyID) else {
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
				newBranch.remove(componentWith: familyID)
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
		branches.modifying { mutableBranches in
			// There should only be one instance where an entity appears.
			mutableBranches.first { $0.contains(entity: entity) }
		}
	}

	private func branch(for entity: Entity) -> Branch? {
		branches
			// There should only be one instance where an entity appears.
			.first { $0.contains(entity: entity) }
	}

	private func branch(for archetype: ComponentArchetype) -> Branch? {
		branches
			// There should only be one instance where an archetype exists
			.first { $0.componentArchetype == archetype }
	}

	private func mutableBranch(for archetype: ComponentArchetype) -> MutableValueReference<Branch>? {
		branches.modifying { mutableBranches in
			// There should only be one instance where an archetype exists.
			mutableBranches.first { $0.componentArchetype == archetype }
		}
	}

	private func newMutableBranch(archetype: ComponentArchetype = []) -> MutableValueReference<Branch> {
		let mutableBranch = MutableValueReference(branchConstructor())

		branches.modifying { mutableBranches in
			mutableBranches.append(mutableBranch)
		}

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
		branch.add(component: Self.self)
	}
}
