//
//  ContainerArray.swift
//  SAKECS
//
//  Created by Stephen Kac on 2/14/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

public protocol ArrayElementContainer: AnyObject {
	associatedtype Element

	var value: Element { get }

	/// Make a deep copy
	var deepCopy: Self { get }
}

extension MutableValueReference: ArrayElementContainer {
	public var deepCopy: MutableValueReference<Element> {
		MutableValueReference(value)
	}
}
