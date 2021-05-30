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

  var ecs: ECSManager?

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    ecs = ECSManagerComposer().compose_v0_0_1()
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    ecs = nil
  }

  /// Tests ECSManager StartUp State
  func testECSManagerInitialization() {
    StartUpCheck: do {
      guard let ecs = ecs else { XCTAssert(false); return }

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
      guard let ecs = ecs else { XCTAssert(false); return }

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
      guard let ecs = ecs else { XCTAssert(false); return }

			let entities = ecs.createEntities(10000)
			guard entities.count == 10000 else { XCTFail("Failed to Create 10000 Entitites"); return }
      XCTAssert(ecs.entitySystem.allEntities.count == 10000)

      for _ in 0..<10000 {
        XCTAssert(ecs.entitySystem.contains(entities.randomElement()!))
      }

      for _ in 0..<10000 {
        let random = entities.randomElement()!
				ecs.destroy(entity: random)
        XCTAssert(!ecs.entitySystem.contains(random))
      }

    }
  }

	func test_regression_removalEventsPerComponentWhenDestroyingEntity() {
		guard let ecs = ecs else { XCTAssert(false); return }

		let entity = ecs.createEntity()!
		ecs.set(component: StringComponent(), to: entity)

		let expectation = XCTestExpectation(description: "Waiting for an event to be fired.")

		let disposable = ecs.events.componentEvent.register(for: .removed(StringComponent.familyID)) { _ in
			expectation.fulfill()
		}

		ecs.destroy(entity: entity)

		wait(for: [expectation], timeout: 1)
		disposable.dispose()
	}

  func testEvents() {

  }

  func testSystems() {

  }

}

// MARK: Private Helper Types
private struct StringComponent: EntityComponent, Equatable {
	static let familyIDStatic: ComponentFamilyID = getFamilyIDStatic()
	var value: String = ""

	init() {}

	internal init(_ value: String) {
		self.value = value
	}
}

private struct IntComponent: EntityComponent, Equatable {
	static let familyIDStatic: ComponentFamilyID = getFamilyIDStatic()
	var value: Int = 2

	init() {}

	internal init(_ value: Int) {
		self.value = value
	}
}

private struct BoolComponent: EntityComponent, Equatable {
	static let familyIDStatic: ComponentFamilyID = getFamilyIDStatic()
	var value: Bool = false

	init() {}

	internal init(_ value: Bool) {
		self.value = value
	}
}
