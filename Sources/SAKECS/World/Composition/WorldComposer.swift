//
//  WorldComposer.swift
//  SAKECS
//
//  Created by Stephen Kac on 2/20/21.
//  Copyright © 2021 Stephen Kac. All rights reserved.
//

import Foundation

struct WorldComposer {

	func composeECSManagerWorld() -> World {
		let adapter = ECSManagerWorldService()
		return World(
			systems: adapter,
			tags: adapter,
			entities: adapter,
			entityComponents: adapter.manager.componentSystem
		)
	}
}
