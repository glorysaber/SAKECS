//
//  ECSTagsTests.swift
//  SAKECSTests
//
//  Created by Stephen Kac on 3/17/19.
//  Copyright © 2019 Stephen Kac. All rights reserved.
//

import XCTest
import SAKECS

class ECSTagsTests: XCTestCase {

  var ecs: ECSManager?

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    ecs = ECSManagerComposer().compose_v0_0_1()
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    ecs = nil
  }

  func tagTestsSetup() -> [Entity] {
    guard let ecs = ecs else { XCTFail("Should not be empty"); return [] }

		let entities = ecs.createEntities(10000)
		guard entities.isEmpty == false else { XCTFail("Should not be empty"); return [] }

    // Adding the Tags
    for entity in entities[0...499] {
      ecs.add(tag: Portion.firstHalf, to: entity)
    }

    for entity in entities[500...999] {
      ecs.add(tag: Portion.secondHalf, to: entity)
    }

    for entity in entities[249...749] {
      ecs.add(tag: Portion.middle, to: entity)
    }

    return entities
  }

  /// Checks tags were added to the entities correctly and then removes a tag from an entity and checks that it is gone
  func testTagQueryAndRemovalOnEntity() {
    guard let ecs = ecs else { assertionFailure(); return }

		let entities = tagTestsSetup()
		guard entities.isEmpty == false else { XCTFail("Should not be empty"); return }

    ecs.add(tag: Portion.delete, to: entities[1])

    do {
      // Checking the tags were added to the correct entities

      for entity in entities[0...499] {
        let tags = try ecs.entitySystem.getTags(for: entity)
        XCTAssert(tags.contains(Portion.firstHalf.rawValue))
        XCTAssert(!tags.contains(Portion.secondHalf.rawValue))
      }

      for entity in entities[500...999] {
        let tags = try ecs.entitySystem.getTags(for: entity)
        XCTAssert(!tags.contains(Portion.firstHalf.rawValue))
        XCTAssert(tags.contains(Portion.secondHalf.rawValue))
      }

      for entity in entities[249...749] {
        let tags = try ecs.entitySystem.getTags(for: entity)
        XCTAssert(tags.contains(Portion.middle.rawValue))
      }
    } catch {
      XCTAssert(false, error.localizedDescription)
    }
  }

  // Checking tag was correctly removed
  func testDeleteingSingleTagFromEntity() {
    guard let ecs = ecs else { XCTFail("Should not be empty"); return }

		let entities = tagTestsSetup()
		guard entities.isEmpty == false else { XCTFail("Should not be empty"); return }

    ecs.remove(tag: Portion.delete, from: entities[1])
    XCTAssert(try !ecs.entitySystem.getTags(for: entities[1]).contains(Portion.delete.rawValue))
  }

  func testGettingEntitiesContainingTags() {
    guard let ecs = ecs else { XCTFail("Should not be empty"); return }

		let entities = tagTestsSetup()
		guard entities.isEmpty == false else { return }

    do {

      // Getting all components with a tag
      let firstHalf = ecs.entitySystem.getEntities(with: [Portion.firstHalf])
      for entity in entities[0...499] { // entities[1] no longer has the tag
        XCTAssert(firstHalf.contains(entity))
      }

      let secondHalf = ecs.entitySystem.getEntities(with: [Portion.secondHalf])
      for entity in entities[500...999] {
        XCTAssert(secondHalf.contains(entity))
      }

      let middle = ecs.entitySystem.getEntities(with: [Portion.middle])
      for entity in entities[249...749] {
        XCTAssert(middle.contains(entity))
      }
    }
  }

  func testGettingEntitiesWithoutTags() {
    guard let ecs = ecs else { XCTFail("Should not be empty"); return }

		let entities = tagTestsSetup()
		guard entities.isEmpty == false else { XCTFail("Should not be empty"); return }

    let firstHalf = ecs.entitySystem.getEntities(without: [Portion.secondHalf])
    for entity in entities[0...499] { // entities[1] no longer has the tag
      XCTAssert(firstHalf.contains(entity))
    }

    let secondHalf = ecs.entitySystem.getEntities(without: [Portion.firstHalf])
    for entity in entities[500...999] {
      XCTAssert(secondHalf.contains(entity))
    }
  }

  func testGettingEntitiesWithMultipleTags() {
    guard let ecs = ecs else { assertionFailure(); return }

		let entities = tagTestsSetup()
		guard entities.isEmpty == false else { XCTFail("Should not be empty"); return }

    let firstHalfOfMiddle = ecs.entitySystem.getEntities(with: [Portion.middle, Portion.firstHalf])
    XCTAssert(firstHalfOfMiddle == Set(entities[249...499]))

    let secondHalfOfMiddle = ecs.entitySystem.getEntities(with: [Portion.middle, Portion.secondHalf])
    XCTAssert(secondHalfOfMiddle == Set(entities[500...749]))
  }

  func testGettingEntitiesWithAnyTags() {
    guard let ecs = ecs else { assertionFailure(); return }

		let entities = tagTestsSetup()
		guard entities.isEmpty == false else { XCTFail("Should not be empty"); return }

    let middleAndFirstHalf = ecs.entitySystem.getEntities(withAny: [Portion.firstHalf, Portion.middle])
		XCTAssertEqual(middleAndFirstHalf, Set(entities[0...749]),
									 "Query result of any with tags [firstHalf, middle] did not contain all expected entities")

    let middleAndSecondHalf = ecs.entitySystem.getEntities(withAny: [Portion.secondHalf, Portion.middle])
    XCTAssertEqual(middleAndSecondHalf, Set(entities[249...999]),
									 "Query result of any with tags [secondHalf, middle] did not contain all expected entities")
  }

  func testTagsAdditionAndRemoval() {
    guard let ecs = ecs else { XCTFail("Should not be empty"); return }

		let entities = ecs.createEntities(100)
		guard entities.isEmpty == false else { XCTFail("Should not be empty"); return }

    enum Tags: String {
      typealias RawValue = String
      case one, two, three, none
    }

		ecs.add(tag: Tags.one, to: entities[0])
		ecs.add(tag: Tags.two, to: entities[1])

    ecs.add(tag: Tags.three, to: entities[2])

    XCTAssertTrue(ecs.entitySystem.contains(Tags.one))

    XCTAssertTrue(ecs.entitySystem.contains(Tags.two))

    XCTAssertTrue(ecs.entitySystem.contains(Tags.three))

    XCTAssertTrue(!ecs.entitySystem.contains(Tags.none))

    ecs.remove(tag: Tags.one, from: entities[0])
  }

}

// MARK: - Helpers
private extension ECSTagsTests {
	enum Portion: String {
		case firstHalf, secondHalf, middle, delete
	}
}
