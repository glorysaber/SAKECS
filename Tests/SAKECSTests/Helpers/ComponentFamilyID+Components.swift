//
//  ComponentFamilyID+Components.swift
//  SAKECSTests
//
//  Created by Stephen Kac on 6/1/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import SAKECS

extension ComponentFamilyID {
	static let int = IntComponent.familyID
	static let bool = BoolComponent.familyID
	static let string = StringComponent.familyID
	static let null = NullComponent.familyID
}
