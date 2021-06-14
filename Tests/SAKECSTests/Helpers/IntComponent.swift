//
//  IntComponent.swift
//  SAKECS
//
//  Created by Stephen Kac on 6/13/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation
import SAKECS

struct IntComponent: EntityComponent, Equatable {
	static let familyIDStatic: ComponentFamilyID = getFamilyIDStatic()
	var value: Int = 2

	init() {}

	internal init(_ value: Int) {
		self.value = value
	}
}

extension IntComponent: ExpressibleByIntegerLiteral {
	init(integerLiteral value: IntegerLiteralType) {
		self.value = value
	}
}
