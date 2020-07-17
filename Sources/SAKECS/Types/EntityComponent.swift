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
//  static var classType: String { get }
}

extension EntityComponent {
/// Gets a component's family ID
  public func familyID() -> ComponentFamilyID {
    return ComponentFamilyID(component: self)
  }

  /// The Family Id of the ComponentType
  public static func familyID() -> ComponentFamilyID {
    return ComponentFamilyID(componentType: self)
  }
}
