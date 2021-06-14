//
//  ECSComponentTests.swift
//  SAKECSTests
//
//  Created by Stephen Kac on 3/17/19.
//  Copyright © 2019 Stephen Kac. All rights reserved.
//

import XCTest
import SAKECS

class ECSComponentTests: XCTestCase {

	// Mark - Adding and Retrieving

  func test_addComponentsAndGetThem() {
    let ecs = makeSUT()

		guard
			let entity = ecs.createEntity()
		else { XCTFail("ECS failed to created entity"); return }

		ecs.set(component: 1, to: entity)
		XCTAssertEqual(ecs.getInt(for: entity), 1)
		XCTAssertEqual(ecs.getBool(for: entity), nil)

		// Add new component and make sure we can still get original component
		ecs.set(component: true, to: entity)
		XCTAssertEqual(ecs.getInt(for: entity), 1)
		XCTAssertEqual(ecs.getBool(for: entity), true)
  }

	func test_addComponentsToTwoEntitesAndGetThem() {
		let ecs = makeSUT()

		guard
			let entity1 = ecs.createEntity(),
			let entity2 = ecs.createEntity()
		else {
			XCTFail("ECS failed to created entity")
			return
		}

		ecs.set(component: 1, to: entity1)
		ecs.set(component: 2, to: entity2)
		ecs.set(component: true, to: entity2)

		XCTAssertEqual(ecs.getInt(for: entity1), 1)
		XCTAssertEqual(ecs.getBool(for: entity1), nil)
		XCTAssertEqual(ecs.getInt(for: entity2), 2)
		XCTAssertEqual(ecs.getBool(for: entity2), true)

	}

	func test_addThreeSeperateComponentsToThreeEntitesAndGetThem() {
		let ecs = makeSUT()

		guard
			let entity1 = ecs.createEntity(),
			let entity2 = ecs.createEntity(),
			let entity3 = ecs.createEntity()
		else {
			XCTFail("ECS failed to created entity")
			return
		}

		ecs.set(component: 1, to: entity1)

		ecs.set(component: true, to: entity2)

		ecs.set(component: "3", to: entity3)

		XCTAssertEqual(ecs.getBool(for: entity2), true)
		XCTAssertEqual(ecs.getInt(for: entity1), 1)
		XCTAssertEqual(ecs.getString(for: entity3), "3")

		// Make sure each only has its own.
		XCTAssertEqual(ecs.getBool(for: entity1), nil)
		XCTAssertEqual(ecs.getInt(for: entity3), nil)
		XCTAssertEqual(ecs.getString(for: entity2), nil)
	}

	func test_setMultipleTimes() {
		let ecs = makeSUT()

		guard
			let entity1 = ecs.createEntity(),
			let entity2 = ecs.createEntity()
		else {
			XCTFail("ECS failed to created entity")
			return
		}

		ecs.set(component: 10, to: entity1)
		ecs.set(component: 100, to: entity1)

		ecs.set(component: 20, to: entity2)
		ecs.set(component: 200, to: entity2)

		XCTAssertEqual(ecs.getInt(for: entity1), 100)
		XCTAssertEqual(ecs.getInt(for: entity2), 200)
	}

	func test_removingComponents() {
		let ecs = makeSUT()

		guard
			let entity1 = ecs.createEntity(),
			let entity2 = ecs.createEntity(),
			let entity3 = ecs.createEntity()
		else {
			XCTFail("ECS failed to created entity")
			return
		}

		ecs.set(component: 1, to: entity1)

		ecs.set(component: true, to: entity2)

		ecs.set(component: false, to: entity3)
		ecs.set(component: "3", to: entity3)
		ecs.remove(componentWith: .string, from: entity3)

		XCTAssertEqual(ecs.getBool(for: entity2), true)
		XCTAssertEqual(ecs.getInt(for: entity1), 1)
		XCTAssertEqual(ecs.getString(for: entity3), nil)

		// Make sure each only has its own.
		XCTAssertEqual(ecs.getBool(for: entity1), nil)
		XCTAssertEqual(ecs.getInt(for: entity3), nil)
		XCTAssertEqual(ecs.getString(for: entity2), nil)
	}
}

// MARK: - Helpers
private extension ECSComponentTests {
	func makeSUT() -> ECSManager {
		ECSManagerComposer().compose_v0_0_2()
	}
}
