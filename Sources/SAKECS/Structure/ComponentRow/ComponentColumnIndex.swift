//
//  ComponentColumnIndex.swift
//  SAKECS
//
//  Created by Stephen Kac on 6/13/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

public typealias ComponentColumnIndices = CountableRange<ComponentColumnIndex>

/// The Index type for a column in a component row
/// This index type has a special provission that it is valid in any ComponentRow
///  that is the same length or more as the original where the indice originated.
public struct ComponentColumnIndex: Comparable {
	public static func < (lhs: ComponentColumnIndex, rhs: ComponentColumnIndex) -> Bool {
		lhs.index < rhs.index
	}

	/// Indexes are only valid when there collection is non empty,
	/// so checking against this value is not enough to know if an index is invalid.
	public static let invalid = ComponentColumnIndex(-1)

	let index: Int

	init(_ index: Int) {
		self.index = index
	}
}

extension ComponentColumnIndex: Strideable {
	public func distance(to other: ComponentColumnIndex) -> Int {
		other.index - index
	}

	public func advanced(by advances: Int) -> ComponentColumnIndex {
		ComponentColumnIndex(self.index + advances)
	}

	public typealias Stride = Int
}

extension ComponentColumnIndices where Bound == ComponentColumnIndex {

	/// Returns an empty Invalid Range, not all empty ranges are invalid.
	/// use the .isEmpty property to check if a range is empty.
	public static let emptyInvalid = ComponentColumnIndices(uncheckedBounds: (.invalid, .invalid))
}

extension ComponentColumnIndex: Hashable {}
