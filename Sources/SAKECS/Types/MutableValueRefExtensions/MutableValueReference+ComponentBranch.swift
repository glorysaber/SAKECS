//
//  MutableValueRef+ComponentBranch.swift
//  SAKECS
//
//  Created by Stephen Kac on 5/28/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation
import SAKBase

extension MutableValueReference: ComponentBranch where Element: ComponentBranch {

	@inlinable
	public var componentArchetype: ComponentArchetype {
		wrappedValue.componentArchetype
	}

	@inlinable
	public var entityCount: Int {
		wrappedValue.entityCount
	}

	@inlinable
	public var componentTypeCount: Int {
		wrappedValue.componentTypeCount
	}

	@inlinable
	public var freeIndexCount: Int {
		wrappedValue.freeIndexCount
	}

	@inlinable
	public var minimumCapacity: Int {
		wrappedValue.minimumCapacity
	}

	@inlinable
	public func contains(entity: Entity) -> Bool {
		wrappedValue.contains(entity: entity)
	}

	@inlinable
	public func add(entity: Entity) {
		wrappedValue.add(entity: entity)
	}

	@inlinable
	public func remove(entity: Entity) {
		wrappedValue.remove(entity: entity)
	}

	@inlinable
	public func contains<Component>(component componentType: Component.Type) -> Bool where Component: EntityComponent {
		wrappedValue.contains(component: componentType)
	}

	@inlinable
	public func set<Component>(
		component: Component,
		for entity: Entity
	) where Component: EntityComponent {
		wrappedValue.set(component: component, for: entity)
	}

	@inlinable
	public func add<Component>(
		component componentType: Component.Type
	) where Component: EntityComponent {
		wrappedValue.add(component: componentType)
	}

	@inlinable
	public func remove<Component: EntityComponent>(
		component componentType: Component.Type
	) {
		wrappedValue.remove(component: componentType)
	}

	@inlinable
	public func get<Component: EntityComponent>(
		component componentType: Component.Type,
		for entity: Entity
	) -> Component? {
		wrappedValue.get(component: componentType, for: entity)
	}

	@inlinable
	public func contains(componentWith familyID: ComponentFamilyID) -> Bool {
		wrappedValue.contains(componentWith: familyID)
	}

	@inlinable
	public func remove(componentWith familyID: ComponentFamilyID) {
		wrappedValue.remove(componentWith: familyID)
	}
}
