//
//  SAKECSTests.swift
//  SAKECSTests
//
//  Created by Stephen Kac on 3/15/19.
//  Copyright © 2019 Stephen Kac. All rights reserved.
//

import XCTest
import SAKECS
import SAKBase

class SAKECSTests: XCTestCase {

  /// Tests ECSManager StartUp State
  func testECSManagerInitialization() {
    StartUpCheck: do {
			let ecs = makeSUT()

      XCTAssert(ecs.active) // Should be active by default

      XCTAssert(ecs.componentCount == 0)
      XCTAssert(ecs.systemTime ~= 0.0000)

			XCTAssertEqual(ecs.systemCount, 0)
      XCTAssertTrue(ecs.entitySystem.allEntities.isEmpty)
      XCTAssertTrue(ecs.entityMasks.isEmpty)
    }
  }

  func testEntityAdditionAndRemoval() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.

    AddingAndRemoval: do {
			let ecs = makeSUT()

      ecs.destroy(entity: ecs.createEntity()!)
      XCTAssertTrue(ecs.entitySystem.allEntities.isEmpty)

      let newEntity = ecs.createEntity()!
      XCTAssert(ecs.entitySystem.allEntities.count == 1)
      XCTAssert(ecs.entitySystem.contains(newEntity))

      ecs.destroy(entity: newEntity)
      XCTAssertTrue(ecs.entitySystem.allEntities.isEmpty)
      XCTAssert(!ecs.entitySystem.contains(newEntity))
    }

    MassAddAndRemoval: do {
			let ecs = makeSUT()

			let entities = ecs.createEntities(1000)
			guard entities.count == 1000 else { XCTFail("Failed to Create 10000 Entitites"); return }
      XCTAssert(ecs.entitySystem.allEntities.count == 1000)

			for entity in entities.shuffled() {
        XCTAssert(ecs.entitySystem.contains(entity))
      }

      for entity in entities.shuffled() {
				ecs.destroy(entity: entity)
        XCTAssert(!ecs.entitySystem.contains(entity))
      }
    }
  }

}

// MARK: - Helpers
private extension SAKECSTests {
	func makeSUT() -> ECSManager {
		ECSManagerComposer().compose_v0_0_1()
	}
}
