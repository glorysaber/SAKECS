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

// Exclusively used to store the familyID in each type that conforms to  EntityComponent.
public struct StaticComponentFamilyID<Component: EntityComponent> {

	/// The Family Id of the ComponentType
	fileprivate var familyID: ComponentFamilyID =
		ComponentFamilyID(componentType: Component.self)

	// Make public once SE-0309 is implemented.
//	public init() {}
}

/// Used to give MultiComponent capabilities
public protocol EntityComponent {

/// Use getFamilyIDStatic
	static var familyIDStatic: ComponentFamilyID { get }

	// Switch to this once SE-0309 is implemented.
//	static var familyIDStatic: StaticComponentFamilyID<Self> { get }

  /// A Type Unique Identifier
	init()
}

extension EntityComponent {

	public var familyID: ComponentFamilyID {
		Self.familyID
	}

	public static var familyID: ComponentFamilyID {
		// Switch to this once SE-0309 is implemented.
//		Self.familyIDStatic.familyID
		Self.familyIDStatic
	}

	// Remove once SE-0309 is implemented.
	public static func getFamilyIDStatic() -> ComponentFamilyID {
		StaticComponentFamilyID<Self>().familyID
	}
}
