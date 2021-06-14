//
//  AnyEntityComponent+Components.swift
//  SAKECS
//
//  Created by Stephen Kac on 6/13/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation
import SAKECS

extension AnyEntityComponent {
	static var int: (Int) -> AnyEntityComponent {
		{ (int: Int) in AnyEntityComponent(component: IntComponent(int)) }
	}
	static var bool: (Bool) -> AnyEntityComponent {
		{ (bool: Bool) in AnyEntityComponent(component: BoolComponent(bool)) }
	}
	static var string: (String) -> AnyEntityComponent {
		{ (string: String) in AnyEntityComponent(component: StringComponent(string)) }
	}
	static let null = AnyEntityComponent(component: NullComponent())
}

extension AnyEntityComponent: ExpressibleByNilLiteral {
	public init(nilLiteral: ()) {
		self = .null
	}
}

extension AnyEntityComponent: ExpressibleByStringLiteral {
	public typealias StringLiteralType = String

	public init(stringLiteral value: String) {
		self = .string(value)
	}
}

extension AnyEntityComponent: ExpressibleByBooleanLiteral {
	public typealias BooleanLiteralType = Bool

	public init(booleanLiteral value: Bool) {
		self = .bool(value)
	}
}

extension AnyEntityComponent: ExpressibleByIntegerLiteral {
	public init(integerLiteral value: IntegerLiteralType) {
		self = .int(value)
	}
}
