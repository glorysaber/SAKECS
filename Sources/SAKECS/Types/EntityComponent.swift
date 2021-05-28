//
//  EntityComponent.swift
//  EmberEngine
//
//  Created by Stephen Kac on 7/15/18.
//

import Foundation

/// Is used to identify a component type
public struct ComponentFamilyID {
  internal let id: ObjectIdentifier
	internal let componentType: EntityComponent.Type

  /// Gets the family ID for the component Type
	fileprivate init<Component: EntityComponent>(componentType: Component.Type) {
		self.id = ObjectIdentifier(componentType)
		self.componentType = componentType
  }
}

extension ComponentFamilyID: Hashable {
	public static func == (lhs: ComponentFamilyID, rhs: ComponentFamilyID) -> Bool {
		lhs.id == rhs.id &&
			lhs.componentType == rhs.componentType
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
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
