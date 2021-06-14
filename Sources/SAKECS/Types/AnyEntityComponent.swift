//
//  AnyEntityComponent.swift
//  SAKECS
//
//  Created by Stephen Kac on 6/13/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

public struct AnyEntityComponent {

	public let component: EntityComponent

	public init(component: EntityComponent) {
		self.component = component
	}
}
