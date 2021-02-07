//
//  ArchetypeBranchTests.swift
//  SAKECSTests
//
//  Created by Stephen Kac on 1/23/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import XCTest
import SAKECS

class ArchetypeBranchTests: XCTestCase {

	func test_canAddEntitiesToChunk() {
		var sut = makeSUT()

		sut.add(entity: 1)
		sut.add(entity: 3)

		XCTAssertEqual(sut.entityCount, 2)
		XCTAssertTrue(sut.contains(1))
		XCTAssertTrue(sut.contains(3))
	}

	func test_doesNotContainEntity() {
		var sut = makeSUT()

		sut.add(entity: 1)
		sut.add(entity: 3)

		XCTAssertFalse(sut.contains(2))
	}

	func test_addingSameEntityDoesNotDuplicate() {
		var sut = makeSUT()

		sut.add(entity: 1)
		sut.add(entity: 1)

		XCTAssertEqual(sut.entityCount, 1)
		XCTAssertTrue(sut.contains(1))
	}

	func test_removeEntity() {
		var sut = makeSUT()

		sut.add(entity: 1)
		sut.add(entity: 2)
		sut.remove(entity: 1)

		XCTAssertEqual(sut.entityCount, 1)
	}

	func test_addComponentToEntity() {
		var sut = makeSUT()

		sut.add(entity: 1)

		sut.add(NullComponent.self)

		XCTAssertEqual(sut.componentTypeCount, 1)
	}

	func test_addsComponentTypeOnlyOnce() {
		var sut = makeSUT()

		sut.add(NullComponent.self)
		sut.add(NullComponent.self)

		XCTAssertEqual(sut.componentTypeCount, 1)
	}

	func test_addsMultipleComponentTypes() {
		var sut = makeSUT()

		sut.add(NullComponent.self)
		sut.add(IntComponent.self)

		XCTAssertEqual(sut.componentTypeCount, 2)
	}

	func test_addComponentAndGetSameOne() {
		var sut = makeSUT()

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

	func test_IndexesBetweenStartAndEndAreValid() {
		let (sut, _) = makeSUT(with: 10)

		XCTAssertEqual(sut.count, 1)

		var index = sut.startIndex
		while index != sut.endIndex {
			_ = sut[index]
			index = sut.index(after: index)
		}
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

	private func makeSUT() -> EntityComponentBranch {
		EntityComponentBranch {
			EntityComponentChunk()
		}
	}

	/// Returns a sut with two component types, Int and Null, with the specified number of columns,
	/// and IntComponents ever increasing in value to match index
	private func makeSUT(with numberOfColumns: Int) -> (EntityComponentBranch, [Entity: IntComponent]) {
		var sut = EntityComponentBranch {
			EntityComponentChunk()
		}

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
