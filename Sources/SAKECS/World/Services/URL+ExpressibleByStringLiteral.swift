//
//  URL+ExpressibleByStringLiteral.swift
//  Universal
//
//  Created by Stephen Kac on 2/18/21.
//  Copyright © 2021 Fanatic Software, Inc. All rights reserved.
//
// 	Initial Source code from:
//  https://www.swiftbysundell.com/tips/defining-static-urls-using-string-literals/

import Foundation
import Require

extension URL: ExpressibleByStringLiteral {
	// By using 'StaticString' we disable string interpolation, for safety
	public init(stringLiteral value: StaticString) {
		self = URL(string: "\(value)").require(hint: "Invalid URL string literal: \(value)")
	}
}
