//
//  ArchetypeChunkTests.swift
//  SAKECSTests
//
//  Created by Stephen Kac on 1/2/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import XCTest
@testable import SAKECS

class ArchetypeChunkTests: XCTestCase {

	func test_canAddEntitiesToChunk() {
		var sut = EntityComponentChunk()

		sut.add(entity: 1)
		sut.add(entity: 3)

		XCTAssertEqual(sut.entityRecordCount, 2)
		XCTAssertTrue(sut.contains(1))
		XCTAssertTrue(sut.contains(3))
	}

	func test_doesNotContainEntity() {
		var sut = EntityComponentChunk()

		sut.add(entity: 1)
		sut.add(entity: 3)

		XCTAssertFalse(sut.contains(2))
	}

	func test_addingSameEntityDoesNotDuplicate() {
		var sut = EntityComponentChunk()

		sut.add(entity: 1)
		sut.add(entity: 1)

		XCTAssertEqual(sut.entityRecordCount, 1)
		XCTAssertTrue(sut.contains(1))
	}

	func test_removeEntity() {
		var sut = EntityComponentChunk()

		sut.add(entity: 1)
		sut.add(entity: 2)
		sut.remove(entity: 1)

		XCTAssertEqual(sut.entityRecordCount, 1)
	}

}
