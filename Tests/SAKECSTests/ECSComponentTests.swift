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

  func testComponent() {
    let ecs = makeSUT()

		let enities = ecs.createEntities(100)
		guard enities.isEmpty == false else { XCTAssert(false, "ECS failed to created 100 entities"); return }

		ecs.set(component: IntComponent(1), to: enities[0])
		XCTAssertEqual(ecs.get(componentType: IntComponent.self, for: enities[0]), .some(IntComponent(1)))
		ecs.set(component: BoolComponent(true), to: enities[0])
		XCTAssertEqual(ecs.get(componentType: IntComponent.self, for: enities[0]), .some(IntComponent(1)))
		XCTAssertEqual(ecs.get(componentType: BoolComponent.self, for: enities[0]), .some(BoolComponent(true)))
  }

}

// MARK: - Helpers
private extension ECSComponentTests {
	func makeSUT() -> ECSManager {
		ECSManagerComposer().compose_v0_0_2()
	}
}

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
