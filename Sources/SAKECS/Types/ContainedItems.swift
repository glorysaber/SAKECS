//
//  ContainedItems.swift
//  EmberEngine-macOS
//
//  Created by Stephen Kac on 7/22/18.
//

import Foundation

/// Will be used to query for entities that matches a specific mix of components and tags
public struct ContainedItems {
  /// The components in a given object
  public internal(set) var components: Set<ComponentFamilyID>

  /// The tags contained in a given object
  public var tags: Set<EntityTag>

  /// Creates a ContainedItems with the given components and tags
  public init(components: [EntityComponent.Type], tags: [EntityTag]) {
    self.components = components.reduce(into: Set<ComponentFamilyID>()) {
			$0.insert($1.familyID)
    }

    self.tags = Set(tags)
  }

  /// Creates an empty ContainedItems
  public init() {
    components = Set<ComponentFamilyID>()
    tags = Set<EntityTag>()
  }

  /// Removes the component
  mutating func remove(component: EntityComponent) {
		removeComponent(with: component.familyID)
  }

  /// adds the component
  mutating func add(component: EntityComponent) {
		addComponent(with: component.familyID)
  }

	/// Removes the component
	mutating func removeComponent(with familyID: ComponentFamilyID) {
		components.remove(familyID)
	}

	/// adds the component
	mutating func addComponent(with familyID: ComponentFamilyID) {
		components.insert(familyID)
	}

}
