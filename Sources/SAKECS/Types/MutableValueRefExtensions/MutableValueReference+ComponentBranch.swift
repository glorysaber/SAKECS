//
//  MutableValueRef+ComponentBranch.swift
//  SAKECS
//
//  Created by Stephen Kac on 5/28/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

extension MutableValueReference: ComponentBranch where Element: ComponentBranch {

	public var componentArchetype: ComponentArchetype {
		wrappedValue.componentArchetype
	}

	public var entityCount: Int {
		wrappedValue.entityCount
	}

	public var componentTypeCount: Int {
		wrappedValue.componentTypeCount
	}

	public var freeIndexCount: Int {
		wrappedValue.freeIndexCount
	}

	public var minimumCapacity: Int {
		wrappedValue.minimumCapacity
	}

	public func reserveCapacity(_ minimumCapcity: Int) {
		wrappedValue.reserveCapacity(minimumCapcity)
	}

	public func contains(_ entity: Entity) -> Bool {
		wrappedValue.contains(entity)
	}

	public func add(entity: Entity) {
		wrappedValue.add(entity: entity)
	}

	public func remove(entity: Entity) {
		wrappedValue.remove(entity: entity)
	}

	public func contains<Component>(_ componentType: Component.Type) -> Bool where Component: EntityComponent {
		wrappedValue.contains(componentType)
	}

	public func set<Component>(
		_ component: Component,
		for entity: Entity
	) where Component: EntityComponent {
		wrappedValue.set(component, for: entity)
	}

	public func add<Component>(
		_ componentType: Component.Type
	) where Component: EntityComponent {
		wrappedValue.add(componentType)
	}

	public func remove<Component>(
		_ componentType: Component.Type
	) where Component: EntityComponent {
		wrappedValue.remove(componentType)
	}

	public func get<Component>(
		_ componentType: Component.Type,
		for entity: Entity
	) -> Component? where Component: EntityComponent {
		wrappedValue.get(componentType, for: entity)
	}

	public func containsComponent(with familyID: ComponentFamilyID) -> Bool {
		wrappedValue.containsComponent(with: familyID)
	}

	public func removeComponent(with familyID: ComponentFamilyID) {
		wrappedValue.removeComponent(with: familyID)
	}
}
