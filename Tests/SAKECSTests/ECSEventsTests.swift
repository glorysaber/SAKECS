//
//  ECSEventsTests.swift
//  SAKECSTests
//
//  Created by Stephen Kac on 6/1/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import XCTest
import SAKECS

class ECSEventsTests: XCTestCase {

	func test_regression_removalEventsPerComponentWhenDestroyingEntity() {
		let ecs = makeSUT()

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

	func test_eventsSentOnRemoval() {
		let ecs = makeSUT()

		let entity = ecs.createEntity()!
		ecs.set(component: StringComponent(), to: entity)

		let expectation = XCTestExpectation(description: "Waiting for an event to be fired.")

		let disposable = ecs.events.componentEvent.register(for: .removed(StringComponent.familyID)) { _ in
			expectation.fulfill()
		}

		ecs.remove(component: StringComponent.self, from: entity)

		wait(for: [expectation], timeout: 1)
		disposable.dispose()
	}

	func test_eventsSentOnAddition() {
		let ecs = makeSUT()

		let entity = ecs.createEntity()!

		let expectation = XCTestExpectation(description: "Waiting for an event to be fired.")

		let disposable = ecs.events.componentEvent.register(for: .added(StringComponent.familyID)) { _ in
			expectation.fulfill()
		}

		ecs.set(component: StringComponent(), to: entity)

		wait(for: [expectation], timeout: 1)
		disposable.dispose()
	}

	func test_eventsSentOnChange() {
		let ecs = makeSUT()

		let entity = ecs.createEntity()!
		ecs.set(component: StringComponent(), to: entity)

		let expectation = XCTestExpectation(description: "Waiting for an event to be fired.")

		let disposable = ecs.events.componentEvent.register(for: .assigned(StringComponent.familyID)) { _ in
			expectation.fulfill()
		}

		ecs.set(component: StringComponent(), to: entity)

		wait(for: [expectation], timeout: 1)
		disposable.dispose()
	}
}

// MARK: - Helpers
private extension ECSEventsTests {
	func makeSUT() -> ECSManager {
		ECSManagerComposer().compose_v0_0_1()
	}
}
