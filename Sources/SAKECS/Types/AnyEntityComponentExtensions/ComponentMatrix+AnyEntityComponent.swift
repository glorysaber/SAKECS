//
//  ComponentMatrix+AnyEntityComponent.swift
//  SAKECS
//
//  Created by Stephen Kac on 6/13/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

public extension ComponentMatrix {
	@inlinable
	mutating func set(
		anyComponent: AnyEntityComponent,
		to index: ComponentColumnIndex
	) {
		anyComponent.component.set(to: &self, to: index)
	}
}

extension EntityComponent {
	@inlinable
	func set(to matrix: inout ComponentMatrix, to index: ComponentColumnIndex) {
		matrix.set(component: self, for: index)
	}
}
