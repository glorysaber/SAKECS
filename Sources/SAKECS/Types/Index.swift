//
//  Index.swift
//  SAKECS
//
//  Created by Stephen Kac on 1/3/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

public protocol Index: Comparable {


	/// An int that only has meaning to the object that created the Index.
	/// No meaning is to be assumed of this value.
	var index: Int { get }
	init(_ index: Int)
	init(index: Int)
}

public extension Index {
	static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.index < rhs.index
	}

	init(_ index: Int) {
		self.init(index: index)
	}
}
