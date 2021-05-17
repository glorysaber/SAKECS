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

	// MARK: ArchetypeGroup

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

	// MARK: Collection

	func test_IndexesBetweenStartAndEndAreValid() {
		let (sut, _) = makeSUT(with: 10)

		XCTAssertGreaterThan(sut.count, 1)

		var index = sut.startIndex
		while index != sut.endIndex {
			_ = sut[index]
			index = sut.index(after: index)
		}
	}

	// MARK: Chunks

	func test_makesProperAmountOfchunks() {
		let (sut, _) = makeSUT(with: 10)

		XCTAssertEqual(sut.count, 5)
	}

	// MARK: Special test cases

	func test_AddingEntitiesBeforeAndAfterTheComponent() {
		var sut = makeSUT()

		sut.add(entity: 1)
		sut.add(entity: 3)

		sut.add(IntComponent.self)

		sut.add(entity: 5)
		sut.add(entity: 6)

		XCTAssertEqual(sut.entityCount, 4)
		XCTAssertNotNil(sut.get(IntComponent.self, for: 5))
	}

	// MARK: Shared Components

	func test_sharedComponents() {
		var sut = makeSUT()

		let numberToTestFor = 4

		sut.setShared(IntComponent(numberToTestFor - 1))

		sut.setShared(IntComponent(numberToTestFor))

		sut.setShared(NullComponent())

		XCTAssertEqual(sut.getShared(IntComponent.self)?.value, numberToTestFor)

		sut.removeShared(IntComponent.self)

		XCTAssertNil(sut.getShared(IntComponent.self))
		XCTAssertNotNil(sut.getShared(NullComponent.self))
	}

	// MARK: Private Helpers

	private struct NullComponent: EntityComponent {
		static let familyIDStatic: ComponentFamilyID = getFamilyIDStatic()
	}
	private struct IntComponent: EntityComponent, Hashable, Comparable {
		static let familyIDStatic: ComponentFamilyID = getFamilyIDStatic()

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
		EntityComponentBranch(columnsInEachChunk: 1) {
			EntityComponentChunk()
		}
	}

	/// Returns a sut with two component types, Int and Null, with the specified number of columns,
	/// and IntComponents ever increasing in value to match index
	private func makeSUT(with numberOfColumns: Int) -> (EntityComponentBranch, [Entity: IntComponent]) {
		var sut = EntityComponentBranch(columnsInEachChunk: 2) {
			EntityComponentChunk()
		}

		sut.add(NullComponent.self)
		sut.add(IntComponent.self)

		var entitiesAndComps = [Entity: IntComponent]()

		for entity in 0..<numberOfColumns {
			sut.add(entity: Entity(entity))
			sut.set(IntComponent(entity), for: Entity(entity))
			entitiesAndComps[Entity(entity)] = IntComponent(entity)
		}

		return (sut, entitiesAndComps)
	}

}
