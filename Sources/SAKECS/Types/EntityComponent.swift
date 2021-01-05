//
//  EntityComponent.swift
//  EmberEngine
//
//  Created by Stephen Kac on 7/15/18.
//

import Foundation

public typealias Component = EntityComponent

/// Is used to identify a component type
public struct ComponentFamilyID: Hashable {
  internal let id: ObjectIdentifier

  /// gets the family ID for the component
  init(component: EntityComponent) {
    self.id = ObjectIdentifier(type(of: component))
  }

  /// Gets the family ID for the component Type
  init(componentType: EntityComponent.Type) {
    self.id = ObjectIdentifier(componentType)
  }
}

/// Used to give MultiComponent capabilities
public protocol EntityComponent {
  /// A Type Unique Identifier
	init()
}

extension EntityComponent {
	/// Gets a component's family ID
	public var familyID: ComponentFamilyID {
    ComponentFamilyID(component: self)
  }

  /// The Family Id of the ComponentType
  public static var familyID: ComponentFamilyID {
		ComponentFamilyID(componentType: self)
  }
}
