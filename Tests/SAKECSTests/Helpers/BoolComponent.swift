//
//  BoolComponent.swift
//  SAKECS
//
//  Created by Stephen Kac on 6/13/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation
import SAKECS

struct BoolComponent: EntityComponent, Equatable {
	static let familyIDStatic: ComponentFamilyID = getFamilyIDStatic()
	var value: Bool = false

	init() {}

	internal init(_ value: Bool) {
		self.value = value
	}
}

extension BoolComponent: ExpressibleByBooleanLiteral {
	init(booleanLiteral value: BooleanLiteralType) {
		self.value = value
	}
}
