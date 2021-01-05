//
//  ComponentRowTests.swift
//  SAKECSTests
//
//  Created by Stephen Kac on 1/3/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import XCTest
import SAKECS

class ComponentRowTests: XCTestCase {

	func test_componentRowStartsEmpty() {
		let sut = ComponentRow<NullComponent>()

		XCTAssertEqual(sut.count, 0)
	}

	func test_componentRowsGrow() {
		var sut = ComponentRow<NullComponent>()

		sut.growColumns(by: 3)

		XCTAssertEqual(sut.count, 3)
	}

	func test_settingAndRetrievingComponentForRow() {
		var sut = ComponentRow<NullComponent>()

		sut.growColumns(by: 3)

		let nullComponent = NullComponent()
		sut[sut.startIndex] = nullComponent

		XCTAssertTrue(sut[sut.startIndex] === nullComponent)
	}

	func test_enumeratingAllElements() {
		var sut = ComponentRow<IntComponent>()

		sut.growColumns(by: 3)

		for (count, index) in sut.indices.enumerated() {
			sut[index] = IntComponent(count)
		}

		for (count, index) in sut.indices.enumerated() {
			XCTAssertEqual(sut[index], IntComponent(count))
		}
	}

	func test_lastAndFirstDoesNotCrashButGivesNil() {
		let sut = ComponentRow<NullComponent>()

		XCTAssertNil(sut.first)
		XCTAssertNil(sut.last)
	}

	func test_lastAndFirstMatchIndexedAndAreNotNil() {
		var sut = ComponentRow<NullComponent>()

		sut.growColumns(by: 2)

		XCTAssertNotNil(sut.first)
		XCTAssertNotNil(sut.last)

		XCTAssertFalse(sut.first !== sut.last)
		XCTAssertTrue(sut[sut.startIndex] === sut.first)
		XCTAssertTrue(sut[sut.index(before: sut.endIndex)] === sut.last)
	}

	func test_enumerationGivesAllComponents() {
		var sut = ComponentRow<NullComponent>()

		sut.growColumns(by: 2)

		var allComponents = [sut.first!, sut.last!]

		sut.makeIterator().forEach { component in
			if let index = allComponents.firstIndex(where: { $0 === component }) {
				allComponents.remove(at: index)
			}
		}

		XCTAssertEqual(allComponents.count, 0)
	}

	private class NullComponent: EntityComponent { required init() {} }
	private struct IntComponent: EntityComponent, Equatable {
		let value: Int

		init() {
			value = -1
		}

		init(_ value: Int) {
			self.value = value
		}
	}

}
