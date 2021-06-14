//
//  StringComponent.swift
//  SAKECS
//
//  Created by Stephen Kac on 6/13/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation
import SAKECS

struct StringComponent: EntityComponent, Equatable {
	static let familyIDStatic: ComponentFamilyID = getFamilyIDStatic()
	var value: String = ""

	init() {}

	internal init(_ value: String) {
		self.value = value
	}
}

extension StringComponent: ExpressibleByStringLiteral {
	init(stringLiteral value: String) {
		self.value = value
	}
}
