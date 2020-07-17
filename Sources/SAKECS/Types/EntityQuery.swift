//
//  EnitityQuery.swift
//  EmberEngine
//
//  Created by Stephen Kac on 7/2/18.
//

import Foundation

/// Will be used to query for entities that matches a specific mix of components and tags
public struct EntityQuery {
	internal var requiredComponents: Set<ComponentFamilyID>
	// Commented out until I find there is a good reason for it.
	internal var illegalComponents: Set<ComponentFamilyID>
	internal var illegalTags: Set<EntityTag>
	internal var requiredTags: Set<EntityTag>

	/// Creates a query that searches by the given requirements
	public init(
		required: [EntityComponent.Type],
		without: [EntityComponent.Type] = [],
		requiredTags: [EntityTag] = [],
		withoutTags illegalTags: [EntityTag] = []) {
		requiredComponents = required.reduce(into: Set<ComponentFamilyID>()) {
			$0.insert(ComponentFamilyID(componentType: $1))
		}

		illegalComponents = without.reduce(into: Set<ComponentFamilyID>()) {
			$0.insert(ComponentFamilyID(componentType: $1))
		}

		self.requiredTags = Set(requiredTags)
		self.illegalTags = Set(illegalTags)
	}

	/// Creates an empty query
	public init() {
		requiredComponents =  Set<ComponentFamilyID>()
		requiredTags = Set<EntityTag>()
		illegalComponents = Set<ComponentFamilyID>()
		self.illegalTags = Set<EntityTag>()
	}

	/// Returns wether this query is satisfied by another query
	internal func isSatisfied(by query: ContainedItems) -> Bool {
		return requiredComponents.isSubset(of: query.components) &&
			requiredTags.isSubset(of: query.tags) &&
			illegalComponents.isDisjoint(with: query.components) &&
			illegalTags.isDisjoint(with: query.tags)
	}
}
