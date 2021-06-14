//
//  ECSManager+Components.swift
//  SAKECS
//
//  Created by Stephen Kac on 6/13/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation
import SAKECS

extension ECSManager {
	func getString(for entity: Entity) -> StringComponent? {
		get(component: StringComponent.self, for: entity)
	}

	func getInt(for entity: Entity) -> IntComponent? {
		get(component: IntComponent.self, for: entity)
	}

	func getNull(for entity: Entity) -> NullComponent? {
		get(component: NullComponent.self, for: entity)
	}

	func getBool(for entity: Entity) -> BoolComponent? {
		get(component: BoolComponent.self, for: entity)
	}
}
