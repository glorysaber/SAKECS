//
//  ComponentMatrixTests.swift
//  SAKECSTests
//
//  Created by Stephen Kac on 1/2/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import XCTest
import SAKECS

class ComponentMatrixTests: XCTestCase {

	func test_addingANewComponentType() {
		var sut = ComponentMatrix()

		XCTAssertFalse(sut.contains(NullComponent.self))
		sut.add(NullComponent.self)

		checkComponentTypeCount(expected: 1, for: sut)
		XCTAssertTrue(sut.contains(NullComponent.self))

		sut.add(NullComponent.self)
		checkComponentTypeCount(expected: 1, for: sut)
	}

	func test_addingNewComponentColumnWithNoTypes() {
		var sut = ComponentMatrix()

		_ = sut.addColumns(1)

		checkComponentTypeCount(expected: 0, for: sut)
		XCTAssertEqual(sut.componentColumns, 0)
	}

	func test_addingNewComponentColumnWithAtLeastOneType() {
		var sut = ComponentMatrix()

		sut.add(NullComponent.self)
		_ = sut.addColumns(1)

		checkComponentTypeCount(expected: 1, for: sut)
		XCTAssertEqual(sut.componentColumns, 1)
	}

	func test_addingSameTypeTwiceReturnsSameColumn() {
		var sut = ComponentMatrix()

		XCTAssertEqual(sut.add(NullComponent.self), sut.add(NullComponent.self))
	}

	func test_removeingComponentType() {
		var sut = ComponentMatrix()

		sut.add(NullComponent.self)
		sut.add(IntComponent.self)

		// There should be two types
		checkComponentTypeCount(expected: 2, for: sut)

		XCTAssertTrue(sut.contains(NullComponent.self))
		sut.remove(NullComponent.self)
		XCTAssertFalse(sut.contains(NullComponent.self))

		// now 1
		checkComponentTypeCount(expected: 1, for: sut)

		sut.remove(NullComponent.self)

		// still 1 since this component does not exist
		checkComponentTypeCount(expected: 1, for: sut)

		sut.remove(IntComponent.self)

		// 0 now that all ahve been removed
		checkComponentTypeCount(expected: 0, for: sut)

		sut.remove(IntComponent.self)

		// still 0
		checkComponentTypeCount(expected: 0, for: sut)
	}

	func test_gettingAllComponentsOfType() {
		var sut = ComponentMatrix()

		var components = sut.get(NullComponent.self)

		XCTAssertTrue(components.isEmpty)

		sut.add(NullComponent.self)
		sut.add(IntComponent.self)
		components = sut.get(NullComponent.self)

		XCTAssertEqual(components.count, 0)

		_ = sut.addColumns(2)
		components = sut.get(NullComponent.self)

		XCTAssertEqual(components.count, 2)
	}

	func test_gettingSameComponentsAsSet() {
		var sut = ComponentMatrix()

		sut.add(IntComponent.self)

		_ = sut.addColumns(3)

		for (count, index) in sut.columnIndices.enumerated() {
			sut.set(IntComponent(count + 1), for: index)
		}

		XCTAssertEqual(sut.get(IntComponent.self, for: sut.columnStartIndex), IntComponent(1))
		XCTAssertEqual(sut.get(IntComponent.self, for: sut.columnIndex(after: sut.columnStartIndex)), IntComponent(2))
		XCTAssertEqual(sut.get(IntComponent.self, for: sut.columnIndex(before: sut.columnEndIndex)), IntComponent(3))
	}

	// MARK: - Collection testing
	func test_enumeratingAllElements() {
		var sut = ComponentMatrix()

		sut.add(IntComponent.self)
		sut.add(NullComponent.self)

		let columns = 3
		let rows = 2

		_ = sut.addColumns(columns)

		for (count, index) in sut.columnIndices.enumerated() {
			sut.set(IntComponent(count), for: index)
		}

		var indexCount = 0

		for index in sut.indices {
			indexCount += 1
			switch sut[index] {
			case let componentRow as ComponentRow<IntComponent>:
				for (count, index) in componentRow.indices.enumerated() {
					XCTAssertEqual(IntComponent(count), componentRow[index])
				}
				XCTAssertEqual(componentRow.count, columns)
			case let componentRow as  ComponentRow<NullComponent>:
				XCTAssertEqual(componentRow.count, columns)
			default:
				XCTFail("Unexpected type")
			}
		}

		XCTAssertEqual(indexCount, rows)
	}

	func test_lastAndFirstDoesNotCrashButGivesNil() {
		let sut = ComponentMatrix()

		XCTAssertNil(sut.first)
		XCTAssertNil(sut.last)
	}

	// regression test
	func test_addingComponentGrowThenAddingAndGettingComponent_DoesNotCrash() {
		var sut = ComponentMatrix()

		sut.add(NullComponent.self)
		let indexes = sut.addColumns(1)
		sut.add(IntComponent.self)

		sut.set(IntComponent(2), for: indexes.first!)
	}

	// MARK: Helpers

	private struct NullComponent: EntityComponent {
		static let familyIDStatic: ComponentFamilyID = getFamilyIDStatic()
	}
	private struct IntComponent: EntityComponent, Hashable, Comparable {
		static let familyIDStatic: ComponentFamilyID = getFamilyIDStatic()

		static func < (lhs: ComponentMatrixTests.IntComponent, rhs: ComponentMatrixTests.IntComponent) -> Bool {
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

	private func checkComponentTypeCount(
		expected: Int, for sut: ComponentMatrix,
		file: StaticString = #filePath,	line: UInt = #line) {

		XCTAssertEqual(sut.containedComponentTypesCount, expected, "reported count does not match", file: file, line: line)
	}
}
