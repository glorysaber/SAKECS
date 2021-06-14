//
//  NullComponent.swift
//  SAKECS
//
//  Created by Stephen Kac on 6/13/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation
import SAKECS

struct NullComponent: EntityComponent {
	static let familyIDStatic: ComponentFamilyID = getFamilyIDStatic()
}

extension NullComponent: ExpressibleByNilLiteral {
	init(nilLiteral: ()) {}
}
