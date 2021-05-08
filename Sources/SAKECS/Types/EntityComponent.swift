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

  /// Gets the family ID for the component Type
	fileprivate init<Component: EntityComponent>(componentType: Component.Type) {
		self.id = ObjectIdentifier(Component.self)
  }
}

private enum StaticComponentFamilyID<Component: EntityComponent> {
	/// The Family Id of the ComponentType
	fileprivate static var familyID: ComponentFamilyID {
		ComponentFamilyID(componentType: Component.self)
	}
}

/// Used to give MultiComponent capabilities
public protocol EntityComponent {
	static var familyID: ComponentFamilyID { get }

  /// A Type Unique Identifier
	init()
}

extension EntityComponent {

	var familyID: ComponentFamilyID {
		Self.familyID
	}

	public static func getFamilyID() -> ComponentFamilyID {
		getFamilyID(type: Self.self)
	}

	private static func getFamilyID<T: EntityComponent>(type: T.Type) -> ComponentFamilyID {
		StaticComponentFamilyID<T>.familyID
	}
}
