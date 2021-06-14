//
//  EntityComponentChunkTests.swift
//  SAKECSTests
//
//  Created by Stephen Kac on 1/2/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import XCTest
import SAKECS

class EntityComponentChunkTests: XCTestCase {

	func test_canAddEntitiesToChunk() {
		var sut = EntityComponentChunk()

		sut.add(entity: 1)
		sut.add(entity: 3)

		XCTAssertEqual(sut.entityCount, 2)
		XCTAssertTrue(sut.contains(entity: 1))
		XCTAssertTrue(sut.contains(entity: 3))
	}

	func test_doesNotContainEntity() {
		var sut = EntityComponentChunk()

		sut.add(entity: 1)
		sut.add(entity: 3)

		XCTAssertFalse(sut.contains(entity: 2))
	}

	func test_addingSameEntityDoesNotDuplicate() {
		var sut = EntityComponentChunk()

		sut.add(entity: 1)
		sut.add(entity: 1)

		XCTAssertEqual(sut.entityCount, 1)
		XCTAssertTrue(sut.contains(entity: 1))
	}

	func test_removeEntity() {
		var sut = EntityComponentChunk()

		sut.add(entity: 1)
		sut.add(entity: 2)
		sut.remove(entity: 1)

		XCTAssertEqual(sut.entityCount, 1)
	}

	func test_addComponentToEntity() {
		var sut = EntityComponentChunk()

		sut.add(entity: 1)

		sut.add(component: NullComponent.self)

		XCTAssertEqual(sut.componentTypeCount, 1)
	}

	func test_addsComponentTypeOnlyOnce() {
		var sut = EntityComponentChunk()

		sut.add(component: NullComponent.self)
		sut.add(component: NullComponent.self)

		XCTAssertEqual(sut.componentTypeCount, 1)
	}

	func test_addsMultipleComponentTypes() {
		var sut = EntityComponentChunk()

		sut.add(component: NullComponent.self)
		sut.add(component: IntComponent.self)

		XCTAssertEqual(sut.componentTypeCount, 2)
	}

	func test_addComponentAndGetSameOne() {
		var sut = EntityComponentChunk()

		sut.add(entity: 1)
		sut.add(component: NullComponent.self)
		sut.add(component: IntComponent.self)

		sut.set(component: IntComponent(2), for: 1)

		XCTAssertEqual(sut.get(component: IntComponent.self, for: 1)?.value, 2)
	}

	func test_addRemovingComponents() {
		var (sut, _) = makeSUT(with: 10)

		XCTAssertTrue(sut.contains(component: NullComponent.self))
		sut.remove(component: NullComponent.self)
		XCTAssertFalse(sut.contains(component: NullComponent.self))
	}

	func test_AddingEntitiesWithTwoChunksAndRemovingComponent() {
		var sut = EntityComponentChunk()

		sut.add(entity: 1)
		sut.add(entity: 2)

		sut.add(component: IntComponent.self)

		sut.add(component: NullComponent.self)

		sut.add(entity: 3)

		// ERROR: SAME INDEX SHARED BETWEEN 4 and 3 in CHUNK 2 when using 2 columns per CHUNK.
		sut.add(entity: 4)

		// Values are not getting changed.
		sut.set(component: IntComponent(1), for: 1)
		sut.set(component: IntComponent(2), for: 2)
		sut.set(component: IntComponent(3), for: 3)
		sut.set(component: IntComponent(4), for: 4)

		XCTAssertEqual(sut.get(component: IntComponent.self, for: 2), IntComponent(2))
		XCTAssertEqual(sut.get(component: IntComponent.self, for: 3), IntComponent(3))

		sut.remove(componentWith: .int)

		XCTAssertNil(sut.get(component: IntComponent.self, for: 2))
		XCTAssertNil(sut.get(component: IntComponent.self, for: 3))
	}

	/// Returns a sut with two component types, Int and Null, with the specified number of columns,
	/// and IntComponents ever increasing in value to match index
	private func makeSUT(with numberOfColumns: Int) -> (EntityComponentChunk, [Entity: IntComponent]) {
		var sut = EntityComponentChunk()

		sut.add(component: NullComponent.self)
		sut.add(component: IntComponent.self)

		var entitiesAndComps = [Entity: IntComponent]()

		for entity in 0...20 {
			sut.add(entity: Entity(entity))
			sut.set(component: IntComponent(entity), for: Entity(entity))
			entitiesAndComps[Entity(entity)] = IntComponent(entity)
		}

		return (sut, entitiesAndComps)
	}

}
