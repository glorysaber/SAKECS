//
//  MutableValueReferenceTests.swift
//  SAKECSTests
//
//  Created by Stephen Kac on 2/13/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import XCTest
import SAKECS

class MutableValueReferenceTests: XCTestCase {

	func test_IsValueMutable() {
		// There is really only one job for this type...
		// This is just a simple test to make sure we fail if
		// its characteristics change...
		let sut = MutableValueReference(1)

		XCTAssertEqual(sut.value, 1)

		let sut2 = sut

		sut.value = 2

		XCTAssertEqual(sut.value, sut2.value)
	}

}
