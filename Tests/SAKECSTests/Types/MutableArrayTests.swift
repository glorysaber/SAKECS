//
//  MutableArrayTests.swift
//  SAKECSTests
//
//  Created by Stephen Kac on 2/12/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import XCTest
import SAKECS

class MutableArrayTests: XCTestCase {

	func test_collection() {
		var sut: MutableArray = [1, 4, 5, 6, 3]

		XCTAssertEqual(sut.count, 5)
		XCTAssertEqual(sut.first, 1)
		XCTAssertEqual(sut.startIndex, 0)
		XCTAssertEqual(sut.endIndex, 5)

		XCTAssertFalse(sut.isEmpty)

		XCTAssertEqual(sut.index(after: sut.endIndex), 6)
		XCTAssertEqual(sut.index(after: sut.startIndex), 1)

		sut[2] = 3

		XCTAssertEqual(sut[2], 3)

		let sut2 = sut

		sut[1] = 0

		XCTAssertEqual(sut2[1], 4)
		XCTAssertEqual(sut[1], 0)
	}

	func test_bidirectionalCollection() {
		let sut: MutableArray = [1, 4, 5, 6, 3]

		XCTAssertEqual(sut.index(before: sut.endIndex), 4)
		XCTAssertEqual(sut.index(before: sut.startIndex), -1)
	}

	func test_print() {
		let values = [1, 4, 5, 6, 3]
		let sut = MutableArray(values)

		XCTAssertEqual(sut.description,
									 values.description)
	}

	func test_mutability() {
		var sut: MutableArray = [1, 4, 5, 6, 3]

		sut[2] = 3

		XCTAssertEqual(sut[2], 3)

		let sut2 = sut

		sut.getContainer(for: 1).wrappedValue = 0

		XCTAssertEqual(sut2[1], 4)
		XCTAssertEqual(sut[1], 0)
	}

}
