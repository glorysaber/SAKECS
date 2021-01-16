//
//  EntityComponentChunkTests.swift
//  SAKECSTests
//
//  Created by Stephen Kac on 1/2/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import XCTest
@testable import SAKECS

class EntityComponentChunkTests: XCTestCase {

	func test_canAddEntitiesToChunk() {
		var sut = EntityComponentChunk()

		sut.add(entity: 1)
		sut.add(entity: 3)

		XCTAssertEqual(sut.entities.count, 2)
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

		XCTAssertEqual(sut.entities.count, 1)
		XCTAssertTrue(sut.contains(1))
	}

	func test_removeEntity() {
		var sut = EntityComponentChunk()

		sut.add(entity: 1)
		sut.add(entity: 2)
		sut.remove(entity: 1)

		XCTAssertEqual(sut.entities.count, 1)
	}

	func test_addComponentToEntity() {
		var sut = EntityComponentChunk()

		sut.add(entity: 1)

		sut.add(NullComponent.self)

		XCTAssertEqual(sut.components.count, 1)
	}

	func test_addsComponentTypeOnlyOnce() {
		var sut = EntityComponentChunk()

		sut.add(NullComponent.self)
		sut.add(NullComponent.self)

		XCTAssertEqual(sut.components.count, 1)
	}

	func test_addsMultipleComponentTypes() {
		var sut = EntityComponentChunk()

		sut.add(NullComponent.self)
		sut.add(IntComponent.self)

		XCTAssertEqual(sut.components.count, 2)
	}

	func test_addComponentAndGetSameOne() {
		var sut = EntityComponentChunk()

		sut.add(entity: 1)
		sut.add(NullComponent.self)
		sut.add(IntComponent.self)

		sut.set(IntComponent(2), for: 1)

		XCTAssertEqual(sut.get(IntComponent.self, for: 1)?.value, 2)
	}

	func test_addRemovingComponents() {
		var (sut, _) = makeSUT(with: 10)

		XCTAssertTrue(sut.contains(NullComponent.self))
		sut.remove(NullComponent.self)
		XCTAssertFalse(sut.contains(NullComponent.self))
	}

	private struct NullComponent: EntityComponent {}
	private struct IntComponent: EntityComponent, Hashable, Comparable {

		static func < (lhs: Self, rhs: Self) -> Bool {
			lhs.value < rhs.value
		}

		let value: Int

		init() {
			self.init(0)
		}

		init(_ value: Int) {
			self.value = value
		}
	}

	/// Returns a sut with two component types, Int and Null, with the specified number of columns,
	/// and IntComponents ever increasing in value to match index
	private func makeSUT(with numberOfColumns: Int) -> (EntityComponentChunk, [Entity: IntComponent]) {
		var sut = EntityComponentChunk()

		sut.add(NullComponent.self)
		sut.add(IntComponent.self)

		var entitiesAndComps = [Entity: IntComponent]()

		for entity in 0...20 {
			sut.add(entity: Entity(entity))
			sut.set(IntComponent(entity), for: Entity(entity))
			entitiesAndComps[Entity(entity)] = IntComponent(entity)
		}

		return (sut, entitiesAndComps)
	}

}
