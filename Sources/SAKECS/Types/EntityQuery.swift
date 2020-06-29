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
  internal var illegalTags: Set<Tag>
  internal var requiredTags: Set<Tag>
  
  /// Creates a query that searches by the given requirements
  public init(required: [EntityComponent.Type], without: [EntityComponent.Type]? = nil, requiredTags: [Tag]? = nil, withoutTags illegalTags: [Tag]? = [Tag]()) {
    requiredComponents = required.reduce(into: Set<ComponentFamilyID>()) {
      $0.insert(ComponentFamilyID(componentType: $1))
    }
    
    illegalComponents = (without ?? [EntityComponent.Type]()).reduce(into: Set<ComponentFamilyID>()) {
      $0.insert(ComponentFamilyID(componentType: $1))
    }
    
    self.requiredTags = Set(requiredTags ?? [Tag]())
    self.illegalTags = Set(illegalTags ?? [Tag]())
  }
  
  /// Creates an empty query
  public init() {
    requiredComponents =  Set<ComponentFamilyID>()
    requiredTags = Set<Tag>()
    illegalComponents = Set<ComponentFamilyID>()
    self.illegalTags = Set<Tag>()
  }
  
  /// Returns wether this query is satisfied by another query
  internal func isSatisfied(by query: ContainedItems) -> Bool {
    return requiredComponents.isSubset(of: query.components) &&
      requiredTags.isSubset(of: query.tags) &&
      illegalComponents.isDisjoint(with: query.components) &&
      illegalTags.isDisjoint(with: query.tags)
  }
}
