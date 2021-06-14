//
//  ComponentArchetype.swift
//  SAKECS
//
//  Created by Stephen Kac on 5/7/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

public struct ComponentArchetype: Hashable {
	public let required: Set<ComponentFamilyID>

	func byAdding(_ ids: ComponentFamilyID...) -> ComponentArchetype {
		byAdding(ids)
	}

	func byAdding<S: Sequence>(_ ids: S) -> ComponentArchetype where S.Element == ComponentFamilyID {
		var required = required
		required.formUnion(ids)
		return ComponentArchetype(required: required)
	}

	func byRemoving(_ ids: ComponentFamilyID...) -> ComponentArchetype {
		byRemoving(ids)
	}

	func byRemoving<S: Sequence>(_ ids: S) -> ComponentArchetype where S.Element == ComponentFamilyID {
		var required = required
		required.subtract(ids)
		return ComponentArchetype(required: required)
	}
}

extension ComponentArchetype: ExpressibleByArrayLiteral {
	public init(arrayLiteral elements: ComponentFamilyID...) {
		self.init(required: Set(elements))
	}

	public init<S: Sequence>(required: S) where S.Element == ComponentFamilyID {
		self.init(required: Set(required))
	}
}

func - (lhs: ComponentArchetype, rhs: ComponentFamilyID) -> ComponentArchetype {
	lhs.byRemoving(rhs)
}

func + (lhs: ComponentArchetype, rhs: ComponentFamilyID) -> ComponentArchetype {
	lhs.byAdding(rhs)
}

// swiftlint:disable shorthand_operator
func -= (lhs: inout ComponentArchetype, rhs: ComponentFamilyID) {
	lhs = lhs - rhs
}

func += (lhs: inout ComponentArchetype, rhs: ComponentFamilyID) {
	lhs = lhs + rhs
}
// swiftlint:enable shorthand_operator
