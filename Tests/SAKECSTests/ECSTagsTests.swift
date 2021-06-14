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

	let middle = 24...74
	let firstHalf = 0...49
	let secondHalf = 50...99

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    ecs = ECSManagerComposer().compose_v0_0_2()
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    ecs = nil
  }

  func tagTestsSetup() -> [Entity] {
    guard let ecs = ecs else { XCTFail("Should not be empty"); return [] }

		let entities = ecs.createEntities(1000)
		guard entities.isEmpty == false else { XCTFail("Should not be empty"); return [] }

    // Adding the Tags
    for entity in entities[0...49] {
      ecs.add(tag: Portion.firstHalf, to: entity)
    }

    for entity in entities[50...99] {
      ecs.add(tag: Portion.secondHalf, to: entity)
    }

    for entity in entities[middle] {
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

      for entity in entities[firstHalf] {
        let tags = try ecs.entitySystem.getTags(for: entity)
        XCTAssert(tags.contains(Portion.firstHalf.rawValue))
        XCTAssert(!tags.contains(Portion.secondHalf.rawValue))
      }

      for entity in entities[50...99] {
        let tags = try ecs.entitySystem.getTags(for: entity)
        XCTAssert(!tags.contains(Portion.firstHalf.rawValue))
        XCTAssert(tags.contains(Portion.secondHalf.rawValue))
      }

      for entity in entities[middle] {
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
      let entitiesWithFirstHalfTag = ecs.entitySystem.getEntities(with: [Portion.firstHalf])
      for entity in entities[firstHalf] { // entities[1] no longer has the tag
        XCTAssert(entitiesWithFirstHalfTag.contains(entity))
      }

      let entitiesWithSecondHalfTag = ecs.entitySystem.getEntities(with: [Portion.secondHalf])
      for entity in entities[secondHalf] {
        XCTAssert(entitiesWithSecondHalfTag.contains(entity))
      }

      let entitiesWithMiddleTag = ecs.entitySystem.getEntities(with: [Portion.middle])
      for entity in entities[middle] {
        XCTAssert(entitiesWithMiddleTag.contains(entity))
      }
    }
  }

  func testGettingEntitiesWithoutTags() {
    guard let ecs = ecs else { XCTFail("Should not be empty"); return }

		let entities = tagTestsSetup()
		guard entities.isEmpty == false else { XCTFail("Should not be empty"); return }

    let entitiesWithFirstHalfTag = ecs.entitySystem.getEntities(without: [Portion.secondHalf])
    for entity in entities[firstHalf] { // entities[1] no longer has the tag
      XCTAssert(entitiesWithFirstHalfTag.contains(entity))
    }

    let entitiesWithSecondHalfTag = ecs.entitySystem.getEntities(without: [Portion.firstHalf])
    for entity in entities[secondHalf] {
      XCTAssert(entitiesWithSecondHalfTag.contains(entity))
    }
  }

  func testGettingEntitiesWithMultipleTags() {
    guard let ecs = ecs else { assertionFailure(); return }

		let entities = tagTestsSetup()
		guard entities.isEmpty == false else { XCTFail("Should not be empty"); return }

    let firstHalfOfMiddle = ecs.entitySystem.getEntities(with: [Portion.middle, Portion.firstHalf])
		XCTAssert(firstHalfOfMiddle == Set(entities[middle.clamped(to: firstHalf)]))

    let secondHalfOfMiddle = ecs.entitySystem.getEntities(with: [Portion.middle, Portion.secondHalf])
		XCTAssert(secondHalfOfMiddle == Set(entities[middle.clamped(to: secondHalf)]))
  }

  func testGettingEntitiesWithAnyTags() {
    guard let ecs = ecs else { assertionFailure(); return }

		let entities = tagTestsSetup()
		guard entities.isEmpty == false else { XCTFail("Should not be empty"); return }

    let middleAndFirstHalf = ecs.entitySystem.getEntities(withAny: [Portion.firstHalf, Portion.middle])
		XCTAssertEqual(middleAndFirstHalf, Set(entities[firstHalf.lowerBound...middle.upperBound]),
									 "Query result of any with tags [firstHalf, middle] did not contain all expected entities")

    let middleAndSecondHalf = ecs.entitySystem.getEntities(withAny: [Portion.secondHalf, Portion.middle])
		XCTAssertEqual(middleAndSecondHalf, Set(entities[middle.lowerBound...secondHalf.upperBound]),
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
